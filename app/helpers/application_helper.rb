module ApplicationHelper
  def hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes["style"] = "display: none"
    end
    content_tag("div", attributes, &block)
  end

  def clean_category(category)
    category.gsub(/[^0-9A-Za-z]/, '')
  end

  def select_delivery_time
    times = []
    current_time = Time.zone.now
    opening_time = Time.zone.now.change({hour: 17})
    closing_time = Time.zone.now.change({hour: 21})
    available_slots = (((closing_time - opening_time)/1.minute)/30).round
    delivery_delay = 60.minutes

    if (current_time >= opening_time) && (current_time <= closing_time)
      current_time_rounded = Time.at((current_time.to_f / 15.minutes).round * 15.minutes).in_time_zone("Pacific Time (US & Canada)")
      delivery_time = current_time_rounded + delivery_delay
      times << ["ASAP (45-60 min)", delivery_time]
      delivery_time += 30.minutes

      # Delivery up until closing time
      while delivery_time <= (closing_time + delivery_delay)
        times << ["#{delivery_time.strftime("%l:%M %P")}", delivery_time]
        delivery_time += 30.minutes
      end
    else
      # Specify delivery for the following day if already too late for same day delivery
      if current_time < opening_time
        next_day = 0
        tomorrow = ""
      elsif current_time > closing_time
        next_day = 1
        tomorrow = "Tomorrow (#{(current_time+1.day).strftime("%a")}) at "
      end

      (0..available_slots).each do |slot|
        delivery_time = opening_time + next_day.days + (slot*30).minutes
        times << ["#{tomorrow + delivery_time.strftime("%l:%M %P")}", delivery_time]
      end
    end
    times
  end
end