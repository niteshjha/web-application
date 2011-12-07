module ApplicationHelper

  def html_attrs(lang = 'en-US')
    {:xmlns => "http://www.w3.org/1999/xhtml", 'xml:lang' => lang, :lang => lang}
  end 

  def trojan_horse_for(name) 
    # creates a hidden <input> field inside a form, pre-populated - 
    # usually by the 'marker' attribute of the containing DOM element
    #   <input type="text" class="hidden" name="student[marker]"

    tag :input, :type => :text, :class => :hidden, :name => "#{name.to_s}[marker]", :trojan => true
  end 

  def make_link (type, options = {})
    # 'dynamic' links are those that load tables and controls on click. Non-dynamic links, 
    # like for logout and login, don't

    name = options.delete(:for).to_s 
    href = options.delete(:href) || '#' 
    with = options.delete(:with) 

    if type == :main
      singular = name.singularize
      plural = name.pluralize
      dynamic = options[:delete].nil? ? true : options[:delete] 
      class_attr = 'main-link'

      if dynamic
         panels = with.blank? ? {:side => "##{plural}-summary"} : with[:panels]
         controls = with.blank? ? "##{singular}-controls" : with[:controls]
      else 
         panels = {} 
         controls = nil 
      end 
    elsif type == :minor 
      class_attr = 'minor-link'
      panels = with.delete(:panels) || {} 
      controls = with.delete(:controls) 
    end 
    
    side = panels.delete :side 
    middle = panels.delete :middle 
    right = panels.delete :right 
    wide = panels.delete :wide 

    link = link_to name, href, :id => "#{name}-link", :class => class_attr, 
                               :side => side, :middle => middle, :right => right, 
                               :wide => wide, 'load-controls' => controls

    return content_tag(:li, link, :id => "#{name}-anchor") 
  end 

  def main_link(options = {}) 
    make_link :main, options 
  end 

  def minor_link(options = {}) 
    make_link :minor, options 
  end 

=begin
   Usage Example : drop_down_menu_for :subjects, :disabled => true, :name => 'subjects[1]'
   Options : 
         :disabled => [true | false] 
         :name => < string > (default = :criterion) 
         :include_blank => [true | false]
         :slider => [true | false] (Sets attribute 'slider=true' attribute on the dropdown) 
=end 

  def drop_down_menu_for (sth, options = {}) 
    collection = nil 

    plural = (sth == :difficulty) ? sth : sth.to_s.pluralize.to_sym
    singular = plural.to_s.singularize

    disabled = options[:disabled].nil? ? false : options[:disabled]
    include_blank = options[:include_blank].nil? ? true : options[:include_blank]
    prefix = options[:name].nil? ? :criterion : options[:name]
    slider = options[:slider].nil? ? false : ((plural == :percentages) && options[:slider]) 

    case plural
      when :boards 
        collection = Board.all 
      when :klasses 
        collection = [*9..12] 
      when :difficulty 
        collection = {:introductory => 1, :intermediate => 2, :advanced => 3}
      when :subjects 
        collection = Subject.all
      when :states 
        collection = ['DL','HR','PB','MH','WB','UP','TN']
      when :percentages 
        collection = 0.step(101,5).to_a 
    end 

    unless collection.nil? || collection.empty?
      select_box = semantic_fields_for prefix do |a| 
                     a.input singular, :as => :select, :collection => collection, 
                     :include_blank => include_blank,
                     :input_html => { :disabled => disabled,
                                      :slider => slider }
                   end 
    end # submitted by params as : criterion => {:state => "MH", :difficulty => "2"}

    class_attr = options[:float].nil? ? 'left dropdown' : 
                      (options[:float] == :right ? 'right dropdown' : 'left dropdown')

    if options[:id].nil? 
      content_tag(:div, select_box, :id => "#{singular}-dropdown", 
                  :class => class_attr)
    else 
      content_tag(:div, select_box, :id => "#{singular}-dropdown", 
                  :class => class_attr, :marker => "#{id}")
    end 
  end # of helper  

  def nofrills_checkbox(options = {}) 
    name = options[:name].nil? ? nil : options[:name]
    float = options[:float].nil? ? :left : options[:float]
    class_attr = (float == :none) ? 'checkbox' : ('checkbox ' + float.to_s)
    label = options[:label].nil? ? false : options[:label]
    
    unless label 
      c = content_tag(:div, tag(:input, :type => 'checkbox', :name => name), :class => class_attr)
    else
      random_id = rand(27**3).to_s(36).upcase
      c = content_tag :div, :class => class_attr do 
            tag(:input, :type => 'checkbox', :name => name, :id => random_id) + 
            content_tag(:label, label, :for => random_id, :class => 'small')
          end 
    end 
    return c 
  end 

end # of helper class
