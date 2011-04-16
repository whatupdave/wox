module Wox
  module NumberHelper
    def plural count, singular, plural
      count == 1 ? singular : plural
    end
    
    def bytes_to_human_size bytes, precision = 1
      kb = 1024
      mb = 1024 * kb
      gb = 1024 * mb
      case 
        when bytes < kb; "%d #{plural(bytes, 'byte', 'bytes')}" % bytes
        when bytes < mb; "%.#{precision}f #{plural((bytes / kb), 'kilobyte', 'kilobytes')}" % (bytes / kb)
        when bytes < gb; "%.#{precision}f #{plural((bytes / mb), 'megabyte', 'megabytes')}" % (bytes / mb)
        when bytes >= gb; "%.#{precision}f #{plural((bytes / gb), 'gigabyte', 'gigabytes')}" % (bytes / gb)
      end
    end
  end
end