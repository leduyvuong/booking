# frozen_string_literal: true

module Admin
  module StatusHelper
    def status_badge_classes(status)
      case status.to_s
      when "confirmed", "available"
        "bg-emerald-100 text-emerald-700"
      when "pending", "partial"
        "bg-amber-100 text-amber-700"
      when "cancelled", "blocked"
        "bg-rose-100 text-rose-700"
      when "full"
        "bg-rose-100 text-rose-700"
      else
        "bg-slate-100 text-slate-600"
      end
    end
  end
end
