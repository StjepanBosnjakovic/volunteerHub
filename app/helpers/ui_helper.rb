module UiHelper
  ICON_DIR = Rails.root.join("app/assets/images/icons")
  ICON_CACHE = {}

  AVATAR_COLORS = %w[
    bg-indigo-600 bg-emerald-600 bg-amber-500 bg-sky-600
    bg-rose-500 bg-violet-600 bg-teal-600 bg-slate-600
  ].freeze

  AVATAR_SIZES = {
    xs: "h-6 w-6 text-[9px]",
    sm: "h-7 w-7 text-[10px]",
    md: "h-8 w-8 text-xs",
    lg: "h-9 w-9 text-xs",
    xl: "h-18 w-18 text-2xl"
  }.freeze

  PILL_TONES = {
    ok:      { pill: "bg-green-100 text-green-800",   dot: "bg-green-500" },
    warn:    { pill: "bg-yellow-100 text-yellow-800", dot: "bg-yellow-500" },
    danger:  { pill: "bg-red-100 text-red-800",       dot: "bg-red-500" },
    info:    { pill: "bg-blue-100 text-blue-800",     dot: "bg-blue-500" },
    brand:   { pill: "bg-indigo-100 text-indigo-700", dot: "bg-indigo-500" },
    accent:  { pill: "bg-orange-100 text-orange-800", dot: "bg-orange-500" },
    neutral: { pill: "bg-gray-100 text-gray-700",     dot: "bg-gray-400" }
  }.freeze

  BAR_TONES = {
    ok: "bg-green-500", warn: "bg-yellow-500", danger: "bg-orange-500", brand: "bg-indigo-600"
  }.freeze

  # Inlines a Lucide icon from app/assets/images/icons.
  def icon(name, size: 18, css: nil)
    svg = ICON_CACHE[name] ||= File.read(ICON_DIR.join("#{name}.svg"))
      .sub(/<!--.*?-->\s*/m, "")
      .sub(/\s*class="[^"]*"/, "")
      .sub(/\s*width="24"/, "")
      .sub(/\s*height="24"/, "")
      .sub('stroke-width="2"', 'stroke-width="1.75"')
    svg.sub("<svg", %(<svg width="#{size}" height="#{size}" aria-hidden="true" class="shrink-0 #{css}")).html_safe
  end

  def initials_for(name)
    name.to_s.split(/[\s@._-]+/).reject(&:blank?).first(2).map { |part| part[0] }.join.upcase
  end

  def avatar(name, size: :lg, css: nil)
    color = AVATAR_COLORS[name.to_s.sum % AVATAR_COLORS.size]
    tag.span initials_for(name),
      class: "inline-flex items-center justify-center rounded-full font-semibold text-white shrink-0 #{color} #{AVATAR_SIZES[size]} #{css}",
      title: name
  end

  def avatar_stack(names, size: :sm, max: 4)
    shown = names.first(max)
    overflow = names.size - shown.size
    tag.span class: "inline-flex -space-x-2" do
      safe_join(shown.map { |n| avatar(n, size: size, css: "ring-2 ring-white") }) +
        (overflow.positive? ? tag.span("+#{overflow}", class: "inline-flex items-center justify-center rounded-full bg-gray-200 text-gray-600 font-semibold ring-2 ring-white #{AVATAR_SIZES[size]}") : "".html_safe)
    end
  end

  def pill(text, tone: :neutral, dot: true, css: nil)
    t = PILL_TONES.fetch(tone)
    tag.span class: "inline-flex items-center gap-1.5 shrink-0 whitespace-nowrap rounded-full px-2.5 py-0.5 text-xs font-semibold #{t[:pill]} #{css}" do
      (dot ? tag.span(class: "h-2 w-2 rounded-full #{t[:dot]}") : "".html_safe) + text
    end
  end

  def progress_bar(percent, tone: :brand, height: "h-1.5")
    tag.div class: "#{height} w-full overflow-hidden rounded-full bg-gray-200" do
      tag.div class: "h-full rounded-full #{BAR_TONES.fetch(tone)}", style: "width: #{percent.clamp(0, 100)}%"
    end
  end

  # Tone and label for a filled/needed pair, as shown on shift rows.
  def fill_status(filled, needed)
    return [:neutral, "#{filled} signed up", 0] if needed.nil? || needed.zero?
    pct = ((filled.to_f / needed) * 100).round.clamp(0, 100)
    tone = pct >= 100 ? :ok : pct >= 60 ? :warn : :danger
    label = pct >= 100 ? "Filled" : "#{needed - filled} needed"
    [tone, label, pct]
  end

  def eyebrow(text, css: nil)
    tag.div text, class: "text-[11px] font-semibold uppercase tracking-widest text-gray-500 #{css}"
  end

  def card_classes(hover: false)
    "rounded-2xl border border-gray-200 bg-white shadow-sm#{' transition-shadow hover:shadow-md' if hover}"
  end

  BUTTON_VARIANTS = {
    primary:   "bg-indigo-600 text-white hover:bg-indigo-700 border border-transparent",
    secondary: "bg-white text-gray-700 hover:bg-gray-50 border border-gray-300",
    ghost:     "bg-transparent text-indigo-600 hover:bg-indigo-50 border border-transparent",
    danger:    "bg-white text-red-600 hover:bg-red-50 border border-red-300"
  }.freeze

  BUTTON_SIZES = {
    sm: "h-8 px-3 text-[13px] rounded-lg gap-1.5",
    md: "h-10 px-4 text-sm rounded-xl gap-2",
    icon: "h-9 w-9 justify-center rounded-lg"
  }.freeze

  def button_classes(variant = :primary, size = :md)
    "inline-flex items-center whitespace-nowrap font-semibold transition-colors cursor-pointer #{BUTTON_VARIANTS.fetch(variant)} #{BUTTON_SIZES.fetch(size)}"
  end

  # Link styled as a button, with an optional leading or trailing icon.
  def button_link(text, url, variant: :primary, size: :md, icon: nil, icon_right: nil, css: nil, **opts)
    link_to url, class: "#{button_classes(variant, size)} #{css}", **opts do
      button_content(text, icon, icon_right, size)
    end
  end

  def button_content(text, leading, trailing, size = :md)
    icon_size = size == :sm ? 15 : 16
    safe_join([
      (icon(leading, size: icon_size) if leading),
      (tag.span(text) if text.present?),
      (icon(trailing, size: icon_size) if trailing)
    ].compact)
  end
end
