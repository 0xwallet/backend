defmodule Backend.EmailService do
  import Bamboo.Email

  @from_addr "auth@owaf.io"

  def auth_email(email, code) do
    new_email()
    |> to(email)
    |> from(@from_addr)
    |> subject("[owaf.io] verification code:")
    |> html_body(body(code))
  end

  defp body(code) do
    """
    <table class="entire-page">
      <tr>
        <td>
          <table class="email-body">
            <tr>
              <td class="email-header">
                <a href="https://owaf.io">
                  <p>OWAF</p>
                </a>
              </td>
            </tr>
            <tr>
              <td class="news-section">
                <strong> Your authentication code is:</strong>
                <h1>#{code}</h1>
              </td>

            </tr>

            <tr>
              <td class="footer">
                Please don't reply this email.
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>
    <style>
    body {
      margin: 0;
    }

    td, p {
      font-size: 13px;
      color: #878787;
    }

    ul {
      margin: 0 0 10px 25px;
      padding: 0;
    }

    li {
      margin: 0 0 3px 0;
    }

    h1, h2 {
      color: black;
    }

    h1 {
      font-size: 25px;
    }

    h2 {
      font-size: 20px;
    }

    a {
      color: #2F82DE;
      font-weight: bold;
      text-decoration: none;
    }

    .entire-page {
      background: #C7C7C7;
      width: 100%;
      padding: 20px 0;
      font-family: 'Lucida Grande', 'Lucida Sans Unicode', Verdana, sans-serif;
      line-height: 1.5;
    }

    .email-body {
      max-width: 600px;
      min-width: 320px;
      margin: 0 auto;
      background: white;
      border-collapse: collapse;
    }
    .email-body img {
      max-width: 100%;
    }

    .email-header {
      background: black;
      padding: 30px;
    }

    .news-section {
      padding: 20px 30px;
    }

    .footer {
      background: #eee;
      padding: 10px;
      font-size: 10px;
      text-align: center;
    }
    </style>
    """
  end
end