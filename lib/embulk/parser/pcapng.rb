require "tempfile"
require "csv"

module Embulk
  module Parser

    class PcapngParserPlugin < ParserPlugin
      Plugin.register_parser("pcapng", self)

      def self.transaction(config, &control)
        p "transaction #{config}, (#{task})"
        idx = 0
        columns = @schema.map{|s|
          Column.new(idx, "#{s['name']}", s['type'].to_sym)
          idx += 1
        }

        yield(task, columns)
      end

      def init
        p "init"
        @schema = @task["schema"]
        p @schema
      end

      def run(file_input)
        p "run"
        while file = file_input.next_file
          tmpf, tmppath = tmppcapng(file.read)
          each_packet(tmppath, @schema.map{|elm| elm.name}) do |hash|
            page_builder.add(hash)
          end
          tmpf.close
        end
        page_builder.finish
      end

      private
      def convert val, type
        v = val.to_s
        v = "" if val == nil
        v = v.to_i if type == :long
        v = v.to_f if type == :float
        return v
      end

      def build_options(fields)
        options = ""
        fields.each do |field|
          options += "-e '#{field}' "
        end
        return options
      end

      def tmppcapng(data)
        tmpf = Tempfile.open("pcapng")
        return tmpf, tmpf.path
      end

      def each_packet(path, fields, &block)
        options = build_options(fields)
        io = IO.popen("tshark -E separator=, #{options} -T fields -r #{path}")
        while line = io.gets
          array = [fields, CSV.parse(line).flatten].transpose
          yield(Hash[*array.flatten])
        end
        io.close
      end

      def fetch_from_pcap(path, fields)
        options = build_options(fields)
        io = IO.popen("tshark -E separator=, #{options} -T fields -r #{path}")
        data = io.read
        io.close
        return data
      end
    end
  end
end
