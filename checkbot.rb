require 'shellwords'

class Checkbot

  attr_accessor :paths, :files, :names, :extensions, :error_count

  def checks

    check_ext_pair 'css', 'less', "CSS files should not be edited directly, LESS files should be edited, then compiled into CSS, with both being checked in."
    check_ext_pair 'less', 'css', "CSS files should be compiled after making changes to Less files."

    check_ext_name '.en.yml', 'defaults.js', "When updating translations, defaults.js should be regenerated."

    check_types_for_strings %w{ .rb .html.erb .html.haml .js .js.erb}, %w{debugger binding.pry}

    check_types_for_strings %w{.js .js.erb}, %w{console alert}

    suggest_if_path_starts_with_any %w{public/javascript public/stylesheets app/view}, "checking your changes across supported browsers, like IE."

    suggest_if_path_starts_with_any %w{app/controllers app/models}, "running tests."

  end

  def checkbot
    @error_count = 0
    banner

    @paths = parse_git_status

    @files = @paths.map{|x| StagedFile.new(x) }

    @names = find_names
    @extensions = find_exts

    checks()

    puts "No problems found =]\n\n" if @error_count == 0
  end

  def find_names
    @files.map{|f| f.name}
  end

  def find_exts
    @files.map{|f| f.ext}
  end

  def check_ext_pair(one, two, tip="")
    one.remove_leading_dot!
    two.remove_leading_dot!

    if @extensions.include?(one) && !@extensions.include?(two)
       error "You staged a '.#{one}' file without staging a '.#{two}' file.  \n  Did you mean to do that?", tip
    end
  end

  def check_ext_name(ext, name, tip="")
    ext.remove_leading_dot!

    if @extensions.include?(ext) && !@names.include?(name)
       error "You staged a '.#{ext}' file without staging '#{name}'.  \n  Did you mean to do that?", tip
    end
  end

  def check_types_for_strings(types, strings, tip="")
    types.each do |type|
      strings.each do |string|
       check_type_for_string type, string, tip
      end
    end
  end

  def check_type_for_string(type, s, tip="")
    type.remove_leading_dot!

    @files.map do |file|
      if file.ext == type && file.grep_count(s).chomp != "0"
        lines = file.grep(s)
        error "You staged '#{file.path}', which contains '#{s}'.  \n  Did you mean to do that? \n\n#{lines}", tip
      end
    end
  end

  def suggest_if_path_starts_with_any(starts, suggestion)
    starts.each do |start|
      suggest_if_path_starts_with(start, suggestion)
    end
  end

  def suggest_if_path_starts_with(s, suggestion)
    @paths.each do |path|
      if path.start_with?(s)
        suggest "You staged files in '#{s}', you should consider #{suggestion}"
        break
      end
    end
  end

  private

  def parse_git_status
    status_lines = `git status -z --porcelain`.split("\x00") #why are lines terminated with nulls?
    staged_lines = status_lines.delete_if{|x| x[0] == " " || x[0] == "?" || x[0] == "D"}
    filenames = staged_lines.map{|x| x[3..-1]}
  end

  def suggest(message)
    puts "~ #{message}"
    puts "\n"
  end

  def error(message, tip="")
    @error_count += 1
    puts "! #{message}"
    puts "  (#{tip})" if !tip.empty?
    puts "\n"
  end

  def banner
    puts %q{
  _._          _____
 [O+O]        |   //|
 < X >        |\\\// |
 _/ \_  _[]___|_\/__|___[]_[]_[]_     

Checkbot is checking staged changes...
    }
  end
end

class String
  def remove_leading_dot!
    if self.start_with? '.'
      self.replace self[1..-1]
    end
  end
end

class StagedFile
  attr_accessor :path, :name, :ext

  def initialize(path)
    @path = Shellwords.shellescape(path)
    @name = path_name(path)
    @ext = path_ext(path)
  end

  def grep(s)
    s = Shellwords.shellescape(s)
    return `grep -n -C3 '#{s}' #{path}`
  end

  def grep_count(s)
    s = Shellwords.shellescape(s)
    return `git diff --unified=0 --cached -p #{path} | grep -c '#{s}'`
  end

  private

  def path_name(s)
    s.split('/').last
  end

  def path_ext(s)
    s.split('.')[1..-1].join('.')
  end
end

if __FILE__ == $PROGRAM_NAME
  Checkbot.new.checkbot
end