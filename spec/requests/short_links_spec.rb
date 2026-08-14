require "rails_helper"

RSpec.describe "Short links", type: :request do
  describe "POST /links" do
    it "creates a short link for a valid URL and returns it on the landing page" do
      post "/links", params: { short_link: { original_url: "https://example.com" } }, as: :html

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("http://localhost:3000/")
      expect(response.body).to include("Copy")
    end

    it "creates a short link for a valid URL via JSON API" do
      post "/links", params: { short_link: { original_url: "https://example.com" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["short_url"]).to match(%r{http://localhost:3000/[A-Za-z0-9]{8}})
    end

    it "returns descriptive missing-scheme validation message via JSON" do
      post "/links", params: { short_link: { original_url: "example.com/path" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      errors = JSON.parse(response.body)["errors"]
      expect(errors["original_url"]).to include("must start with http:// or https:// (example: https://example.com).")
    end

    it "returns descriptive unsupported-scheme validation message via JSON" do
      post "/links", params: { short_link: { original_url: "ftp://example.com" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      errors = JSON.parse(response.body)["errors"]
      expect(errors["original_url"]).to include("must use http:// or https://. Other schemes are not supported.")
    end

    it "returns a distinct required message for blank input in HTML" do
      post "/links", params: { short_link: { original_url: "" } }, as: :html

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Please enter a destination URL.")
      expect(response.body).not_to include("must start with http:// or https://")
    end

    it "allows correction and successful resubmission after a validation failure" do
      post "/links", params: { short_link: { original_url: "example.com/path" } }, as: :html

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must start with http:// or https://")

      post "/links", params: { short_link: { original_url: "https://example.com/path" } }, as: :html

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Your shortened link")
      expect(response.body).to include("Copy")
    end
  end

  describe "GET /:alias" do
    it "does not treat the /links page as an alias lookup" do
      get "/links"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Link shortener")
    end

    it "redirects a valid short link to its destination" do
      short_link = ShortLink.create!(original_url: "https://example.com", alias: "ABCD1234", expires_at: 1.day.from_now)

      get "/#{short_link.alias}"

      expect(response).to redirect_to(short_link.original_url)
    end

    it "shows an expired-link state for expired aliases" do
      short_link = ShortLink.create!(original_url: "https://example.com", alias: "EXPIRED1", expires_at: 1.day.ago)

      get "/#{short_link.alias}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("expired")
    end
  end
end
