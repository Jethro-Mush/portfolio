defmodule PortfolioWeb.PortfolioLiveTest do
  use PortfolioWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, ~p"/")

    assert disconnected_html =~ "Rimwell Jethro Mushilingwa"
    assert render(page_live) =~ "Rimwell Jethro Mushilingwa"
    assert render(page_live) =~ "Engineering Resilient"
    assert render(page_live) =~ "Stanbic Bank"
  end

  test "filtering projects by category", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    # Filter by fintech
    render_click(view, "filter_projects", %{"category" => "fintech"})
    html = render(view)
    assert html =~ "Stanbic Bank"
    assert html =~ "Probase Limited"
    assert html =~ "Atlas Mara"

    # Filter by enterprise
    render_click(view, "filter_projects", %{"category" => "enterprise"})
    html = render(view)
    assert html =~ "Zambia Railways"
    assert html =~ "Engineering Institute of Zambia"
  end

  test "opening and closing project details modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute render(view) =~ "The Engineering Challenge"

    # Open Stanbic Bank system details
    render_click(view, "open_project", %{"id" => "stanbic-regulatory"})
    html = render(view)
    assert html =~ "The Engineering Challenge"
    assert html =~ "Architectural Solution"
    assert html =~ "Measurable Business Impact"
    assert html =~ "Central Bank-mandated"

    # Close modal
    render_click(view, "close_project", %{})
    refute render(view) =~ "The Engineering Challenge"
  end

  test "toggling professional referees", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute render(view) =~ "Head of Computer Section"

    # Toggle open
    render_click(view, "toggle_referees", %{})
    html = render(view)
    assert html =~ "Mr. Boyd Chanza"
    assert html =~ "Mr. Mutale"
    assert html =~ "Miss Mercy Kashompa"

    # Toggle closed
    render_click(view, "toggle_referees", %{})
    refute render(view) =~ "Head of Computer Section"
  end

  test "contact form validation and reactive submission", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    # Change with invalid email
    render_change(view, "validate_contact", %{
      "contact" => %{"name" => "", "email" => "invalid-email", "message" => ""}
    })

    html = render(view)
    assert html =~ "Your name is required"
    assert html =~ "Please provide a valid email address"
    assert html =~ "Please write a brief message"

    # Submit with valid data
    render_submit(view, "send_contact", %{
      "contact" => %{
        "name" => "Enterprise Partner",
        "email" => "partner@bank.com",
        "subject" => "Senior FinTech Role",
        "message" => "We would love to discuss a senior engineering opportunity."
      }
    })

    assert render(view) =~ "Message Sent Successfully!"
    assert render(view) =~ "Rimwell will review your inquiry"

    # Reset contact form
    render_click(view, "reset_contact", %{})
    refute render(view) =~ "Message Sent Successfully!"
    assert render(view) =~ "Send a Direct Message"
  end

  test "copying contact information updates state, displays flash notification, and clears after timeout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    # Click copy email
    render_click(view, "copy_text", %{"field" => "email", "value" => "Mushilingwaj@Gmail.Com"})
    html = render(view)

    # Flash notification and button state rendered
    assert html =~ "Copied Email address to clipboard"
    assert html =~ "Mushilingwaj@Gmail.Com"
    assert html =~ "Copied!"

    # Test :clear_copied lifecycle
    send(view.pid, :clear_copied)
    html_after = render(view)
    refute html_after =~ "Copied!"
  end
end
