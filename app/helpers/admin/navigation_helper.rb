# frozen_string_literal: true

module Admin
  module NavigationHelper
    ICONS = {
      "chart-bar" => "M3.75 3v18h16.5V3H3.75zm3 4.5h2.25v9H6.75v-9zm4.5 3h2.25v6h-2.25v-6zm4.5-3h2.25v9h-2.25v-9z",
      "user-group" => "M13 7a4 4 0 11-8 0 4 4 0 018 0zm5 5a3 3 0 11-6 0 3 3 0 016 0zm-5 6a6 6 0 00-12 0v1.5h12V18zm2.25-4.5c-.54 0-1.06.08-1.55.23.55.75.88 1.68.88 2.69V18h4.5v-.58a4.42 4.42 0 00-3.83-4.42z",
      "calendar" => "M6 2a1 1 0 011 1v1h10V3a1 1 0 112 0v1h1a2 2 0 012 2v13a2 2 0 01-2 2H3a2 2 0 01-2-2V6a2 2 0 012-2h1V3a1 1 0 112 0v1zm-3 6v11h18V8H3zm3 3h4v4H6v-4z",
      "clipboard" => "M9 2a2 2 0 00-2 2v1H6a2 2 0 00-2 2v11a2 2 0 002 2h12a2 2 0 002-2V7a2 2 0 00-2-2h-1V4a2 2 0 00-2-2H9zm0 3h6V4H9v1zm0 4h8v2H9V9zm0 4h8v2H9v-2z",
      "clock" => "M12 3a9 9 0 100 18 9 9 0 000-18zm.75 4.5a.75.75 0 10-1.5 0v5.25c0 .414.336.75.75.75h4.5a.75.75 0 100-1.5h-3.75V7.5z"
    }.freeze

    def admin_nav_link(label, path, icon:)
      active = current_page?(path)
      base_classes = "flex items-center space-x-3 px-3 py-2 rounded-md text-sm font-medium"
      classes = if active
                  "bg-slate-800 text-white"
                else
                  "text-slate-300 hover:bg-slate-800 hover:text-white"
                end

      link_to path, class: [base_classes, classes].join(" ") do
        safe_join([heroicon(icon), content_tag(:span, label)])
      end
    end

    private

    def heroicon(name)
      path = ICONS[name]
      return unless path

      content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "currentColor", class: "h-5 w-5") do
        content_tag(:path, nil, d: path)
      end
    end
  end
end
