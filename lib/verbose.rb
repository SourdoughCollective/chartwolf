def verbose(message)
  if VERBOSE
    if message.is_a?(String)
      puts "#{message}"
    elsif message.is_a?(Symbol)
      puts "#{DIALOGUE_ARRAY[message]}"
    end
  end
end
