defmodule PortfolioWeb.PortfolioLive.Index do
  use PortfolioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    projects = list_projects()
    skills = list_skills()
    experience = list_experience()
    education = list_education()
    referees = list_referees()
    hobbies = list_hobbies()

    socket =
      socket
      |> assign(:page_title, "Rimwell Jethro Mushilingwa | Full-Stack Software Developer")
      |> assign(:projects, projects)
      |> assign(:filtered_projects, projects)
      |> assign(:active_filter, "all")
      |> assign(:selected_project, nil)
      |> assign(:skills, skills)
      |> assign(:experience, experience)
      |> assign(:education, education)
      |> assign(:referees, referees)
      |> assign(:hobbies, hobbies)
      |> assign(:show_referees, false)
      |> assign(:copied_field, nil)
      |> assign(:contact_form, %{
        "name" => "",
        "email" => "",
        "subject" => "",
        "message" => ""
      })
      |> assign(:contact_errors, %{})
      |> assign(:message_sent, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("filter_projects", %{"category" => category}, socket) do
    filtered =
      case category do
        "all" -> socket.assigns.projects
        cat -> Enum.filter(socket.assigns.projects, &(&1.category == cat))
      end

    {:noreply, socket |> assign(:active_filter, category) |> assign(:filtered_projects, filtered)}
  end

  @impl true
  def handle_event("open_project", %{"id" => id}, socket) do
    project = Enum.find(socket.assigns.projects, &(&1.id == id))
    {:noreply, assign(socket, :selected_project, project)}
  end

  @impl true
  def handle_event("close_project", _params, socket) do
    {:noreply, assign(socket, :selected_project, nil)}
  end

  @impl true
  def handle_event("toggle_referees", _params, socket) do
    {:noreply, assign(socket, :show_referees, !socket.assigns.show_referees)}
  end

  @impl true
  def handle_event("copy_text", %{"field" => field, "value" => value}, socket) do
    label =
      case field do
        "email" -> "Email address"
        "phone" -> "Phone number"
        "location" -> "Address"
        _ -> "Information"
      end

    Process.send_after(self(), :clear_copied, 2500)

    {:noreply,
     socket
     |> assign(:copied_field, field)
     |> put_flash(:info, "Copied #{label} to clipboard: #{value}")}
  end

  @impl true
  def handle_event("validate_contact", %{"contact" => params}, socket) do
    errors = validate_contact_params(params)
    {:noreply, socket |> assign(:contact_form, params) |> assign(:contact_errors, errors)}
  end

  @impl true
  def handle_event("send_contact", %{"contact" => params}, socket) do
    errors = validate_contact_params(params)

    if map_size(errors) == 0 do
      {:noreply,
       socket
       |> assign(:message_sent, true)
       |> assign(:contact_form, %{"name" => "", "email" => "", "subject" => "", "message" => ""})
       |> assign(:contact_errors, %{})}
    else
      {:noreply, socket |> assign(:contact_form, params) |> assign(:contact_errors, errors)}
    end
  end

  @impl true
  def handle_event("reset_contact", _params, socket) do
    {:noreply, assign(socket, :message_sent, false)}
  end

  @impl true
  def handle_info(:clear_copied, socket) do
    {:noreply,
     socket
     |> assign(:copied_field, nil)
     |> clear_flash(:info)}
  end

  defp validate_contact_params(params) do
    errors = %{}

    errors =
      if String.trim(params["name"] || "") == "" do
        Map.put(errors, :name, "Your name is required")
      else
        errors
      end

    email = String.trim(params["email"] || "")

    errors =
      cond do
        email == "" ->
          Map.put(errors, :email, "Email address is required")

        not String.contains?(email, "@") or not String.contains?(email, ".") ->
          Map.put(errors, :email, "Please provide a valid email address")

        true ->
          errors
      end

    errors =
      if String.trim(params["message"] || "") == "" do
        Map.put(errors, :message, "Please write a brief message")
      else
        errors
      end

    errors
  end

  defp list_projects do
    [
      %{
        id: "stanbic-regulatory",
        category: "fintech",
        badge: "Banking & Compliance",
        client: "Stanbic Bank Zambia",
        title: "Regulatory Reporting & Compliance Engine",
        headline: "Cut reporting turnaround times by 85% with automated multi-tier bank auditing.",
        summary:
          "Architected and led the development team building Stanbic Bank's automated regulatory reporting system. Replaced legacy manual spreadsheets and reconciliation pipelines with high-speed compliance validation, direct data warehousing ingestion, and automated report submissions.",
        metrics: [
          %{label: "Efficiency Gain", value: "85%"},
          %{label: "Role", value: "Team Lead & Developer"},
          %{label: "Verification", value: "Real-Time Audit"}
        ],
        tech_stack: ["Elixir / Phoenix", "PostgreSQL", "MS SQL Server", "Docker", "GitLab CI", "APIs"],
        challenge:
          "Stanbic Bank faced extensive manual overhead and operational latency aggregating inter-departmental transactions into Central Bank-mandated reporting formats with tight deadlines.",
        solution:
          "Engineered an automated data extraction and transformation pipeline with strict financial integrity checks, role-based approval gates, audit trails, and automated export generators.",
        impact:
          "Reduced quarterly compliance preparation from days to hours, boosting institutional efficiency by 85% and eradicating reconciliation human errors."
      },
      %{
        id: "probase-gateway",
        category: "fintech",
        badge: "Payment Infrastructure",
        client: "Probase Limited",
        title: "High-Concurrency Universal Payment Gateway",
        headline: "Resilient transaction processing engine handling thousands of concurrent requests.",
        summary:
          "Engineered the core Probase Payment Gateway to bridge financial institutions, mobile network operators (MTN, Airtel, Zamtel), and merchants. Implemented robust failover queuing, transaction idempotency, and ISO8583 message parsing.",
        metrics: [
          %{label: "Throughput", value: "High Concurrency"},
          %{label: "Reliability", value: "99.98% Uptime"},
          %{label: "Integrations", value: "MNOs & Banks"}
        ],
        tech_stack: ["Elixir", "PostgreSQL", "Redis", "Docker", "REST APIs", "Linux"],
        challenge:
          "Merchant checkouts and utility billers experienced transaction drops and latency spikes during peak payment hours and intermittent telecom network outages.",
        solution:
          "Architected an event-driven transaction processor featuring automated retries, smart routing across payment rails, secure callback webhooks, and instant settlement notifications.",
        impact:
          "Achieved seamless 24/7 transaction uptime, high throughput, and zero duplicate charges across millions of kwacha in digital payments."
      },
      %{
        id: "atlas-mara-asset",
        category: "fintech",
        badge: "Asset Management",
        client: "Atlas Mara Bank",
        title: "Web-Based Fund & Asset Management Platform",
        headline: "Complete digitization of portfolio operations, approvals, and portfolio reporting.",
        summary:
          "Designed and delivered a comprehensive web-based fund and wealth management system for Atlas Mara. Digitized core financial workflows including client portfolio monitoring, asset allocation tracking, tier-based executive approvals, and investor statement generation.",
        metrics: [
          %{label: "Workflows", value: "100% Paperless"},
          %{label: "Domain", value: "Wealth & Treasury"},
          %{label: "Security", value: "Role-Based Auth"}
        ],
        tech_stack: ["Full-Stack Web", "MS SQL Server", "REST APIs", "Tailwind CSS", "JavaScript"],
        challenge:
          "Asset managers and compliance officers were relying on fragmented spreadsheets and manual paper sign-offs for high-value portfolio adjustments and client statements.",
        solution:
          "Delivered an intuitive, single-pane-of-glass portal enabling real-time valuation, automated fee calculations, multi-level sign-off workflows, and instantaneous PDF statement generation.",
        impact:
          "Enhanced regulatory audit readiness, streamlined institutional client onboarding, and established end-to-end transparency across portfolio operations."
      },
      %{
        id: "fnb-banklink",
        category: "fintech",
        badge: "Corporate Banking",
        client: "First National Bank (FNB)",
        title: "Banklink Multi-Bank Client Portal",
        headline: "Integrated multi-bank connectivity driving a 30% increase in digital transaction volumes.",
        summary:
          "Developed FNB's Banklink Client Portal, connecting corporate clients with multiple commercial banks for bulk payments, payroll disbursement, and automated statement reconciliation through unified banking APIs.",
        metrics: [
          %{label: "Volume Growth", value: "+30%"},
          %{label: "Target", value: "Corporate Clients"},
          %{label: "Reconciliation", value: "Automated"}
        ],
        tech_stack: ["JavaScript", "Python", "Oracle DB", "Docker", "Secure APIs"],
        challenge:
          "Corporate clients with accounts across multiple banking partners struggled with tedious manual reconciliations and disparate login portals.",
        solution:
          "Engineered a unified corporate client portal with secure host-to-host multi-bank messaging, scheduled batch payroll runs, and instant transaction verification.",
        impact:
          "Boosted FNB's corporate transaction volumes by 30% within months of launch while dramatically accelerating client daily balance reconciliations."
      },
      %{
        id: "qfin-loans",
        category: "fintech",
        badge: "Microfinance & Credit",
        client: "QFin Zambia",
        title: "Automated Loan Underwriting & Management System",
        headline: "Digitized end-to-end credit assessment, reducing manual underwriting effort by 60%.",
        summary:
          "Built a modern Loan Management System for QFin to handle the complete lifecycle of microfinance and consumer lending: credit scoring, document uploads, loan disbursement scheduling, and automated repayment tracking.",
        metrics: [
          %{label: "Processing Speed", value: "3x Faster"},
          %{label: "Manual Effort", value: "-60%"},
          %{label: "Default Tracking", value: "Automated Alerts"}
        ],
        tech_stack: ["Web Technologies", "PostgreSQL", "JavaScript", "REST APIs", "Linux"],
        challenge:
          "Lengthy paper-based loan applications and manual credit score evaluations caused customer churn and delayed disbursement times.",
        solution:
          "Designed a fast web portal with built-in credit criteria rules, amortization schedule calculators, automated SMS reminders, and payment gateway hookups.",
        impact:
          "Reduced loan turnaround from several days to under 4 hours, dramatically boosting QFin's customer satisfaction and portfolio growth."
      },
      %{
        id: "zambia-railways-fleet",
        category: "enterprise",
        badge: "Transport & Logistics",
        client: "Zambia Railways Limited",
        title: "Locomotive & Fleet Telematics Management Platform",
        headline: "Unified real-time fleet tracking, preventive maintenance planning, and incident reporting.",
        summary:
          "Implemented an enterprise-grade fleet management solution for Zambia Railways. Connected locomotives, maintenance depots, and logistics controllers into a centralized tracking and operational dashboard.",
        metrics: [
          %{label: "Coverage", value: "National Grid"},
          %{label: "Maintenance", value: "Predictive & Timed"},
          %{label: "Operational Uptime", value: "+40%"}
        ],
        tech_stack: ["Python", "JavaScript", "MS SQL Server", "GPS / Telematics APIs", "Docker"],
        challenge:
          "Difficulty monitoring train positions, fuel consumption, locomotive mechanical status, and scheduling timely depot maintenance across national corridors.",
        solution:
          "Engineered a real-time telematics dashboard with GPS mapping, sensor data alerts, scheduled maintenance calendar, and automated incident triage dispatch.",
        impact:
          "Significantly lowered train downtime, prevented fuel pilferage, and enabled executive management to track freight transit times with precision."
      },
      %{
        id: "eiz-evoting",
        category: "enterprise",
        badge: "GovTech & Civic",
        client: "Engineering Institute of Zambia (EIZ)",
        title: "Cryptographic E-Voting & National Election Platform",
        headline: "Tamper-proof digital election platform ensuring 100% auditability and fair elections.",
        summary:
          "Delivered an online e-voting platform for the Engineering Institute of Zambia. Built with rigorous cryptographic verification, single-use authentication tokens, zero voter coercion safeguards, and live tally auditing.",
        metrics: [
          %{label: "Integrity", value: "100% Auditable"},
          %{label: "Voter Turnout", value: "Record High"},
          %{label: "Tally Time", value: "Instantaneous"}
        ],
        tech_stack: ["Elixir / Phoenix", "PostgreSQL", "Crypto / Hashing", "HTML5/CSS", "GitLab CI"],
        challenge:
          "Physical ballot casting across nationwide engineering branches was expensive, logistically complex, and susceptible to counting disputes.",
        solution:
          "Developed an accessible, secure digital ballot system with two-factor OTP authentication, anonymous cryptographic voter balloting, and tamper-evident audit logs.",
        impact:
          "Facilitated transparent leadership elections with widespread member participation and instant, dispute-free results certified by independent observers."
      },
      %{
        id: "dssl-ticketing",
        category: "mobile",
        badge: "Mobile & Transit",
        client: "DSSL",
        title: "High-Volume Mobile Ticketing & Validation App",
        headline: "Offline-first QR code ticketing and transit reservation ecosystem.",
        summary:
          "Currently leading full-stack and mobile implementations for a next-generation ticketing application at DSSL. Features fast QR code scanning, offline cryptographic ticket validation, multi-channel payment integration, and real-time backend synchronization.",
        metrics: [
          %{label: "Status", value: "Active Development"},
          %{label: "Platform", value: "Cross-Platform Mobile"},
          %{label: "Validation Speed", value: "< 200ms"}
        ],
        tech_stack: ["Flutter", "React Native", "Elixir / Phoenix Backend", "PostgreSQL", "Docker"],
        challenge:
          "High commuter volumes require ultra-fast ticket scans even in underground stations or areas with spotty cellular connectivity.",
        solution:
          "Built an offline-first cryptographic ticket generator and scanner with asynchronous backend queue syncing when connection restores.",
        impact:
          "Provides frictionless boarding, zero duplicate ticket fraud, and comprehensive sales analytics for transit operators."
      }
    ]
  end

  defp list_skills do
    [
      %{
        category: "Core Languages & Runtimes",
        icon: "hero-code-bracket",
        items: [
          %{name: "Elixir", level: "Expert / Core", exp: "5+ Years", highlight: true},
          %{name: "Phoenix & LiveView", level: "Expert / Core", exp: "5+ Years", highlight: true},
          %{name: "JavaScript (ES6+)", level: "Advanced", exp: "5+ Years", highlight: true},
          %{name: "Python", level: "Proficient", exp: "4 Years", highlight: false},
          %{name: "C++", level: "Solid Foundation", exp: "Academic & Systems", highlight: false}
        ]
      },
      %{
        category: "Web & Frontend Technologies",
        icon: "hero-globe-alt",
        items: [
          %{name: "HTML5 & Semantic Markup", level: "Expert", exp: "5+ Years", highlight: false},
          %{name: "CSS3 & Modern Tailwind", level: "Expert", exp: "5+ Years", highlight: true},
          %{name: "Responsive & Accessible UI", level: "Advanced", exp: "5+ Years", highlight: false},
          %{name: "JSON & RESTful APIs", level: "Expert", exp: "5+ Years", highlight: true},
          %{name: "WebSockets & Real-Time Channels", level: "Advanced", exp: "4 Years", highlight: true}
        ]
      },
      %{
        category: "Mobile Application Development",
        icon: "hero-device-phone-mobile",
        items: [
          %{name: "Flutter", level: "Advanced", exp: "Cross-Platform iOS/Android", highlight: true},
          %{name: "React Native", level: "Proficient", exp: "Mobile Apps", highlight: true},
          %{name: "Offline-First Sync", level: "Advanced", exp: "Mobile Architecture", highlight: false},
          %{name: "Mobile Device APIs", level: "Proficient", exp: "Camera, GPS, Biometrics", highlight: false}
        ]
      },
      %{
        category: "Databases & Data Storage",
        icon: "hero-circle-stack",
        items: [
          %{name: "PostgreSQL", level: "Expert", exp: "High Concurrency & Tuning", highlight: true},
          %{name: "MS SQL Server", level: "Advanced", exp: "Enterprise Banking Systems", highlight: true},
          %{name: "Oracle Database", level: "Proficient", exp: "Corporate Portals", highlight: false},
          %{name: "Database Indexing & Normalization", level: "Advanced", exp: "Performance Tuning", highlight: false}
        ]
      },
      %{
        category: "DevOps & Cloud Engineering",
        icon: "hero-server-stack",
        items: [
          %{name: "Docker & Containerization", level: "Advanced", exp: "Containerized Deployment", highlight: true},
          %{name: "Git, GitHub & GitLab", level: "Expert", exp: "Team Branching & Code Review", highlight: false},
          %{name: "GitLab CI / CD Pipelines", level: "Advanced", exp: "Automated Build & Test", highlight: true},
          %{name: "Linux Server Administration", level: "Proficient", exp: "Production Deployment", highlight: false},
          %{name: "System Security & Auth", level: "Advanced", exp: "OAuth2, JWT, Role-Based Access", highlight: false}
        ]
      },
      %{
        category: "Architecture & Professional Practice",
        icon: "hero-check-badge",
        items: [
          %{name: "High-Concurrency FinTech Architecture", level: "Proven Track Record", exp: "Banks & Gateways", highlight: true},
          %{name: "Team Collaboration & Mentorship", level: "Demonstrated Leadership", exp: "Technical Team Lead", highlight: false},
          %{name: "System Troubleshooting & Debugging", level: "Tenacious", exp: "Production Triage", highlight: false},
          %{name: "Clear Technical Documentation", level: "Strong", exp: "Architecture & Specs", highlight: false}
        ]
      }
    ]
  end

  defp list_experience do
    [
      %{
        period: "August 2026 – Present",
        role: "Full Stack Developer",
        company: "DSSL",
        location: "Lusaka, Zambia",
        current: true,
        summary:
          "Developing and maintaining full-stack software solutions tailored to complex business and user requirements. Collaborating with cross-functional development teams in designing, implementing, testing, and improving mission-critical application functionality.",
        achievements: [
          "Currently spearheading key features for a high-volume mobile ticketing application, optimizing real-time validation and transit backend synchronizations.",
          "Collaborating with product teams in architectural planning, API contract definition, and UX workflow streamlining.",
          "Conducting comprehensive code reviews, writing unit and integration tests, and authoring technical documentation across the full SDLC."
        ],
        tags: ["Flutter", "React Native", "Elixir", "PostgreSQL", "Docker", "Mobile Ticketing"]
      },
      %{
        period: "April 2020 – August 2026",
        role: "Software Developer & Technical Lead",
        company: "Probase Limited",
        location: "Lusaka, Zambia",
        current: false,
        summary:
          "Served over 6 years architecting, designing, testing, and deploying enterprise financial, logistics, and government applications. Collaborated with interdisciplinary teams to ensure rigorous code quality, high availability, and cutting-edge software architecture.",
        achievements: [
          "Designed and delivered a web-based fund/asset management platform for Atlas Mara, digitizing core portfolio operations, executive approvals, and reporting.",
          "Built the Probase Payment Gateway to process high-volume concurrent transactions, improving processing stability, failover, and merchant settlement.",
          "Developed Stanbic Bank's Regulatory Reporting System as team lead & core developer, elevating operational efficiency by 85% over legacy manual methods.",
          "Engineered FNB's Banklink Client Portal, integrating multi-bank interfaces and driving corporate digital transaction volume up by 30%.",
          "Implemented a national fleet management solution for Zambia Railways, unifying locomotive GPS telematics, depot maintenance planning, and reporting.",
          "Delivered a cryptographic e-voting platform for the Engineering Institute of Zambia (EIZ), ensuring transparent, verifiable, and dispute-free elections.",
          "Developed an automated Loan Management System for QFin, dramatically reducing underwriting turnaround times and manual document processing."
        ],
        tags: ["Elixir / Phoenix", "Stanbic Bank", "Atlas Mara", "FNB", "Payment Gateways", "MS SQL Server", "PostgreSQL", "Docker"]
      },
      %{
        period: "January 2020 – March 2020",
        role: "Customer Call Center Care Executive",
        company: "ISON Experiences",
        location: "Lusaka, Zambia",
        current: false,
        summary:
          "Proactively connected with customers across calls and digital channels to address inquiries, gather vital product feedback, and resolve complex issues. Engaged in targeted sales outreach and upselling.",
        achievements: [
          "Promoted MTN AYO Insurance — Zambia's first mobile phone health and life insurance solution — successfully extending outreach into rural and underserved communities.",
          "Demonstrated exceptional customer rapport, conflict resolution, and communication skills under demanding service-level agreements."
        ],
        tags: ["Customer Engagement", "MTN AYO Insurance", "Strategic Communication", "Client Support"]
      }
    ]
  end

  defp list_education do
    [
      %{
        year: "2025",
        degree: "Bachelor's Degree in Computer Science",
        institution: "ZCAS University",
        location: "Lusaka, Zambia",
        badge: "Higher Education",
        description: "Specialized in Software Engineering, Advanced Algorithms, Database Systems, Distributed Computing, and Information Security."
      },
      %{
        year: "2024",
        degree: "Advanced Certificate in Software Engineering",
        institution: "ALX Africa",
        location: "Remote / Pan-African Program",
        badge: "Professional Certification",
        description: "Intensive 12-month software engineering program emphasizing low-level programming, data structures, full-stack web development, team pair-programming, and system design."
      },
      %{
        year: "2019",
        degree: "Secondary Teachers Diploma – Computer Science with Mathematics",
        institution: "Evelyn Hone College of Applied Arts and Commerce",
        location: "Lusaka, Zambia",
        badge: "Diploma",
        description: "Dual focus on Computer Science and Mathematics, building strong pedagogical, analytical, and problem-solving foundations."
      },
      %{
        year: "2014",
        degree: "High School Certificate",
        institution: "Lusaka High School",
        location: "Lusaka, Zambia",
        badge: "Secondary Education",
        description: "Completed secondary education with distinguished performance in science and mathematics."
      }
    ]
  end

  defp list_referees do
    [
      %{
        name: "Mr. Boyd Chanza",
        role: "Software Developer Supervisor",
        organization: "Remote / Probase",
        location: "Lusaka, Zambia",
        phone: "+260973767852",
        linkedin: "https://www.linkedin.com/in/danny-kalaluka-b271a616a/",
        relationship: "Direct Technical Supervisor on Enterprise FinTech Projects"
      },
      %{
        name: "Mr. Mutale",
        role: "Head of Computer Section",
        organization: "Evelyn Hone College of Applied Arts and Commerce",
        location: "Lusaka, Zambia",
        phone: "0965 317436",
        email: "brianmutale3@gmail.com",
        relationship: "Academic Department Head & Computer Science Mentor"
      },
      %{
        name: "Miss Mercy Kashompa",
        role: "Call Center Team Lead",
        organization: "ISON Experiences",
        location: "Lusaka, Zambia",
        phone: "+260 96 6220078",
        relationship: "Team Lead & Operations Supervisor"
      }
    ]
  end

  defp list_hobbies do
    [
      %{name: "Polyglot Coding & Languages", icon: "hero-language", desc: "Exploring new programming paradigms, languages, and linguistics."},
      %{name: "Music & Singing", icon: "hero-musical-note", desc: "Singing and learning musical instruments to foster creative thinking."},
      %{name: "Chess & Strategy", icon: "hero-puzzle-piece", desc: "Playing competitive chess to sharpen analytical and forward-planning skills."},
      %{name: "Soccer & Fitness", icon: "hero-trophy", desc: "Active team soccer and outdoor athletics."},
      %{name: "Nature Exploration", icon: "hero-sparkles", desc: "Recharging through outdoor hikes, landscapes, and wildlife wonders."},
      %{name: "Avid Reading", icon: "hero-book-open", desc: "Continuous learning across engineering, technology trends, and biographies."}
    ]
  end
end
