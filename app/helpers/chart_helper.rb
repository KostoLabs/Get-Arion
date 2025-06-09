module ChartHelper
  def svg_donut_chart(accounts, total, currency, options = {})
    inner_radius = options[:inner_radius] || 75
    outer_radius = options[:outer_radius] || 105
    center_x = options[:center_x] || 120
    center_y = options[:center_y] || 120

    current_angle = 0
    paths = []

    accounts.each do |account|
      next if account.balance.to_f <= 0

      angle = (account.balance.to_f / total) * 360
      path_data = calculate_arc_path(center_x, center_y, inner_radius, outer_radius, current_angle, current_angle + angle)
      color = account.accountable_type == "FinancialLiability" ? "#EF4444" : account.accountable.color

      paths << {
        path: path_data,
        color: color,
        label: account.accountable.display_name,
        value: account.balance,
        percentage: account.weight
      }

      current_angle += angle
    end

    render 'shared/svg_donut_chart', paths: paths, total: total, currency: currency
  end

  private

  def calculate_arc_path(cx, cy, inner_r, outer_r, start_angle, end_angle)
    start_angle_rad = (start_angle - 90) * Math::PI / 180
    end_angle_rad = (end_angle - 90) * Math::PI / 180

    start_x = cx + outer_r * Math.cos(start_angle_rad)
    start_y = cy + outer_r * Math.sin(start_angle_rad)
    end_x = cx + outer_r * Math.cos(end_angle_rad)
    end_y = cy + outer_r * Math.sin(end_angle_rad)

    inner_start_x = cx + inner_r * Math.cos(start_angle_rad)
    inner_start_y = cy + inner_r * Math.sin(start_angle_rad)
    inner_end_x = cx + inner_r * Math.cos(end_angle_rad)
    inner_end_y = cy + inner_r * Math.sin(end_angle_rad)

    large_arc = (end_angle - start_angle) > 180 ? 1 : 0

    "M #{start_x} #{start_y} A #{outer_r} #{outer_r} 0 #{large_arc} 1 #{end_x} #{end_y} L #{inner_end_x} #{inner_end_y} A #{inner_r} #{inner_r} 0 #{large_arc} 0 #{inner_start_x} #{inner_start_y} Z"
  end
end
