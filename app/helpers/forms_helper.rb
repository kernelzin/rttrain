#
#
# Just Form POST stuff!!!!
#
#
module FormsHelper
  #
  #
  #
  #  Forms
  #
  #
  # ftext
  # fpass
  # farea
  # fi18n
  # fdrop
  # fdate
  # ffile
  # fcheck
  # fradio
  #
  def i18n_attr(f, attr = nil)
    return unless f.object
    key = f.object.class.try(:model_name).try(:i18n_key)
    key = "mongoid.attributes.#{key}"
    attr ? "#{key}.#{attr}" : key
  end

  def should_translate?(f, method_name)
    f.object.respond_to?("#{method_name}_translations")
  end

  def i18n_set? key
    I18n.t key, raise: true rescue false
  end

  def fi18n(f, attr, opts ={})
    will_translate = should_translate?(f, attr)
    content_tag(:div, class: "form-group #{'base-lang-changer' if will_translate}") do
      out = []
      out << content_tag(:label, class: 'control-label', for: i) do
        _out = []
        _out << i18n_attr(f, attr)
        _out << language_change_select if will_translate
        _out.join.html_safe
      end

      if will_translate
        languages.each do |_name, abbr|
          m_name = "#{f.object_name}[#{sanitize(attr.to_s)}_translations][#{abbr}]"
          new_opts = opts.merge(
            id: "#{f.object_name}_#{i}_#{abbr}",
            class: "#{opts[:class]} lang-#{abbr} #{'hide' if I18n.locale.to_s != abbr.to_s}",
            name: m_name,
            value: f.object.send("#{i}_translations")[abbr]
          )
          out << f.send(method_name, i, new_opts)
        end
      end
    end
    fbase(f, attr, :text_field, opts)
  end

  def ftext(f, attr, opts = {})
    fbase(f, attr, :text_field, opts)
  end

  def fpass(f, attr, opts = {})
    fbase(f, attr, :password_field, opts)
  end

  def farea(f, attr, opts = {})
    fbase(f, attr, :text_area, opts)
  end

  def ffile(f, attr, opts = {})
    # fbase(f, attr, :file_field, opts)
    content_tag(:div, class: 'form-group') do
      out = opts[:nolabel] ? '' : f.label(attr)
      out << f.file_field(attr, opts)
      out.html_safe
    end
  end

  def fdate(f, attr, opts = {})
    value = f.object[attr] ? l(f.object.send(attr), format: :app) : nil
    fbase(f, attr, :text_field, opts.merge(value: value, class: 'datepick'))
  end

  def ftime(f, attr, opts = {})
    value = f.object[attr] ? l(f.object.send(attr), format: :app) : nil
    fbase(f, attr, :text_field, opts.merge(value: value, class: 'timepick'))
  end

  def fbase(f, attr, method_name, opts = {})
    key = i18n_attr(f, attr)
    hint = !opts[:nohint] && i18n_set?("#{key}_hint") ? t("#{key}_hint") : nil
    opts[:class] = "form-control #{opts[:class]}"
    opts[:placeholder] = t("#{key}_holder") if i18n_set?("#{key}_holder")
    content_tag(:div, class: 'form-group') do
      out = f.label(attr)
      out << f.send(method_name, attr, opts)
      out << hint if hint
      out
    end
  end

  def link_active?(regex)
    request.path =~ /#{regex}/
  end

  def dropf(ary)
    return [] unless ary
    ary.map { |i| [i.to_s, i.id] }
  end

  def fdrop(f, attr, collection, html = {}, opts = {})
    klass = opts.delete(:class)
    # label = true if label.nil?
    content_tag(:div, class: 'form-group') do
      out =  opts[:nolabel] ? '' : f.label(attr)
      out << f.select(attr, collection, opts, html.merge(class: "form-control #{klass}"))
      out.html_safe
    end
  end

  def fsel2(f, i, collection = [], html = {}, opts = {})
    label = opts.delete(:label)
    klass = opts.delete(:class)
    label = true if label.nil?
    content_tag(:div, class: 'form-group') do
      if label
        label = content_tag(:label, class: 'control-label', for: i) do
          t("mongoid.attributes.#{i18n_attr(f)}.#{i}".to_sym)
        end
      end
      control = f.select i, collection, opts, html.merge(class: "selectize #{klass}")
      label ? label + control : control
    end
  end

  def fdropo(f, i, html = {}, opts = {})
    collection = Fact.find_by(name: i).options.map { |o| [o.to_s, o.id] } rescue []
    fdrop(f, i, collection, html, opts)
  end

  def fcheck(f, attr, opts = {})
    content_tag(:div, class: 'checkbox') do
      content_tag(:label, class: opts[:label_class]) do
        f.check_box(attr, opts) + f.object.class.human_attribute_name(attr)
      end
    end
  end

  def fsbox(f, m, opts = {}) # , upper_space=true)
    help = opts.delete(:help) || ''
    # content = opts.delete(:content) || ''
    unless help.empty?
      help = content_tag(:a,
                         class: 'btn btn-sm btn-info pop input-group-addon',
                         title: help[:title], 'data-content' => help[:content],
                         'data-placement' => help[:placement],
                         'data-toggle' => :popover) { fa_icon('question') }
    end
    out = content_tag(:div, class: 'input-group form-group clickable') do
      content_tag(:div, class: 'input-group-addon') do
        f.check_box(m, opts)
      end + f.label(m, class: 'form-control') + help
    end

    # if upper_space
    #   out = content_tag(:div, class: 'form-group') do
    #     content_tag(:label) { '&nbsp;'.html_safe } + out
    #   end
    # end

    out
  end

  def fradio(f, attr, options, opts = {})
    klass = 'btn btn-default '
    klass += opts[:class] if opts[:class]
    content_tag(:div, class: 'btn-group', 'data-toggle' => 'buttons') do
      options.map do |k, v|
        aklass = f.object.send(attr) == k ? "#{klass} active" : klass
        content_tag(:label, class: aklass) do
          (f.radio_button(attr, k, autocomplete: 'off') + v).html_safe
        end
      end.join.html_safe
    end
    # help = opts.delete(:help) || ''
    # content = opts.delete(:content) || ''
    # if !help.empty?
    #   help = content_tag(:a,
    #    class: 'btn btn-sm btn-info pop input-group-addon',
    #    title: help[:title],
    #    'data-content' => help[:content],
    #    'data-placement' => help[:placement],
    #    'data-toggle' => :popover) { fa_icon('question') }
    # end
  end

  def fcash(f, sym, opts = {}, _args = {})
    content_tag(:div, class: 'control-group') do
      content_tag(:label, class: 'control-label', for: sym) do
        t("mongoid.attributes.#{f.object.class.model_name.i18n_key}.#{sym}".to_sym) unless opts[:label] == false
      end +
        content_tag(:div, class: 'controls') do
          content_tag(:div, class: "input-prepend #{opts[:div_class]}") do
            content_tag(:span, 'R$', class: "add-on  #{opts[:span_class]}") +
              f.text_field(sym, class: opts[:class])
          end
        end
    end
  end

  #
  # Save / Back / Cancel
  #
  #
  def back_link(txt = nil, link = nil, opts = {})
    opts[:class] ||= 'btn-lg btn-info'
    link ||= request.referrer if request.referrer && !request.referrer.empty? && !(request.referrer =~ /new|edit/)
    link ||= { controller: controller.controller_name, action: :index } if respond_to?(:controller)
    link_to (txt || fa_icon('arrow-left')), (link || :back), class: "btn tip #{opts[:class]}", title: t('cancel'), 'data-toggle' => 'tooltip', 'data-placement' => 'bottom'
  end

  def save_btn(text, title = nil, opts = {})
    content_tag(
      :button,
      text,
      type:  'submit',
      name:  opts[:name] || 'commit',
      class: opts[:class],
      title: title,
      'data-toggle' => :tooltip,
      'data-placement' => :bottom,
      'data-loading-text' => '...'
      )
  end

  def save_or_cancel(_f, opts = {})
    opts[:class] = 'btn tip btn-loading btn-default'
    snew = '' if opts[:new] == false
    snew ||= save_btn fa_icon('plus'), t('save_new'), opts.merge(name: 'tonew')
    save_opts = opts.merge(class: opts[:class] + ' btn-wide btn-primary')
    content_tag(:div, class: 'form-actions') do
      content_tag(:div, class: 'pull-right') do
        content_tag(:div, class: 'btn-group', role: 'group') do
          back_link(fa_icon('times'), opts[:back], opts) +
            save_btn(fa_icon('check'), t(:save), save_opts) + snew
        end
      end
    end
  end


  #
  # Formataistisimpletastic!
  #
  # def ffield(f, sym, type = nil, opts = {}, args = {})
  #   out = "<div class='field #{type || 'text'} control-group' data-role='fieldcontain'>"
  #   out << f.label(sym, class: 'control-label')
  #   control = case type
  #   when :area, :text then f.text_area(sym, size: '4x4')
  #   when :bool then f.check_box(sym)
  #   when :drop then f.select(sym, opts.delete(:vals), opts, args.merge('data-native-menu' => 'false'))
  #   when :date then f.datetime_select(sym, use_short_month: true)
  #   when :slide then f.range_field(sym, opts)
  #   else f.text_field(sym, opts.merge(class: 'input-text big'))
  #   end
  #   out += "<div class='controls'>#{control}</div>"
  #   if hint = opts[:hint]
  #     out << content_tag(:span, class: 'note') do
  #       hint
  #     end
  #   end
  #   out << '</div>'
  #   raw(out)
  # end

end
