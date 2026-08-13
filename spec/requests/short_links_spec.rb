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

    it "rejects invalid URLs with a validation message via JSON" do
      post "/links", params: { short_link: { original_url: "ftp://example.com" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("original_url")
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
