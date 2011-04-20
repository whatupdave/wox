module Wox
  class Task
    def run_command text, options
      result = `#{text}`
      
      File.open(options[:results], "w") {|f| f.write result }
      
      if $?.to_i == 0
        puts "Success. Results in #{options[:results]}"
        puts
      else
        fail exec "cat #{options[:results]}"
      end
    end
    
  end
end