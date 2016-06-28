if ARGV.first == '-h'
  puts "ruby conferences.rb [filename=conferences.md] [dir=TD]"
else
  # Arguments
  filename = ARGV.first || 'conferences.md'
  dir = ARGV[1] || 'TD'
  # Setup
  conferences = Hash.new {|h,k| h[k] = []}
  cluster = nil
  node_counter = month_counter = 0
  output = "digraph conferences {\n  rankdir=#{dir};\n\n"
  # Generate graph based on filename lines starting with "## month" and "- conferenceName description"
  IO.foreach(filename) {|line|
    # New month
    if line.start_with?('##')
      # Close and save previous cluster
      output << cluster << "  }\n\n" if cluster
      cluster = "  subgraph cluster_#{month_counter} {\n    label=\"#{line.split[1]}\";\n    order_node_#{month_counter} [style=invis];\n"
      month_counter += 1
    # New node
    elsif line.start_with?('-')
      item = line.split
      item.shift
      conferences[item.first] << "node_#{node_counter}"
      cluster << "    node_#{node_counter} [label=\"#{item.join('\n')}\"];\n"
      node_counter += 1
    end
  }
  # Close and save last cluster
  output << cluster << "  }\n\n" if cluster

  # Add edges between conference parts
  conferences.each_value {|parts| output << '  ' << parts.join(' -> ') << ";\n" if parts.size > 1}
  # Add invisible edges between months to enforce order
  output << "\n"
  month_counter.pred.times {|i| output << "  order_node_#{i} -> order_node_#{i.succ} [style=invis];\n"}
  output << '}'
  # Save file
  IO.write("#{filename}.dot", output)
end