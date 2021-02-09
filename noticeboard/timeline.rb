#!/usr/bin/env ruby
#-----------------------------------------------
# Timeline
#-----------------------------------------------
# Mau Magnaguagno
#-----------------------------------------------

if ARGV.first == '-h'
  puts 'ruby conferences.rb [filename=README.md] [dir=LR]'
else
  # Arguments
  filename = ARGV.first || 'README.md'
  dir = ARGV[1] || 'LR'
  # Setup
  conferences = Hash.new {|h,k| h[k] = []}
  url = {}
  cluster = nil
  node_counter = month_counter = 0
  output = "digraph conferences {\n  rankdir=#{dir}\n\n"
  # Generate graph based on filename lines starting with "## month" and "- conferenceName description"
  
  timeline = false
  IO.foreach(filename) {|line|
    # Skip stuff until the conference timeline
    if line.start_with?('# Conference Timeline')
      timeline = true
    end
    # Month
    if timeline and line.start_with?('##')
      # Close and save previous cluster
      output << cluster << "  }\n\n" if cluster
      cluster = "  subgraph cluster_#{month_counter} {\n    graph[height=1.65]\n    label=\"#{line.split[1]}\"\n    order_node_#{month_counter} [shape=point label=\"\" style=invis]\n"
      month_counter += 1
    # Node
    elsif timeline and line.start_with?('-')
      line.delete!('[]')
      item = line.split
      item.shift
      conferences[item.first] << "node_#{node_counter}"
      cluster << "    node_#{node_counter} [shape=box label=\"#{item.join('\n')}\" URL=\"#{url[item.first].first}\" tooltip=\"#{url[item.first].last}\" target=\"_blank\"]\n"
      node_counter += 1
    # URL
    elsif timeline and line.start_with?('[')
      line =~ /^\[(.+)\]: ([^\s]+) "(.*)"/
      url[$1] = [$2, $3]
    end
  }
  # Close and save last cluster
  output << cluster << "  }\n\n" if cluster

  # Add edges between conference parts
  conferences.each_value {|parts| output << '  ' << parts.join(' -> ') << "\n" if parts.size > 1}
  # Add invisible edges between months to enforce order
  output << "\n"
  month_counter.pred.times {|i| output << "  order_node_#{i} -> order_node_#{i.succ} [style=invis]\n"}
  output << '}'
  # Save file
  IO.write("#{filename}.dot", output)
end