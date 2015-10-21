#!/usr/local/ruby
=begin
  Simple utility for fixing any "done()" issues that can crop up with a migration from QUnit 1.x to 2.x

  Untested outside of simple examples, but it should work. Licensed under the "Revised BSD License" see LICENSE file.
  

  Usage: ruby DoneMover.rb </path/to/file> > </path/to/new/file> where > is the redirect operator of your shell
=end

if (ARGV.length != 1)
  puts "Usage: </path/to/file>: Moves the done's() or the equivalant to the appropriate place "
else
  lines = []

  File.open(ARGV[0]).each do |line|
    lines.push line
  end

  inTest = false
  indentCount = 0
  variableNames = []
  curLine = 0

  while curLine != lines.length
    line = lines[curLine]

    case line.chomp
    when /QUnit\.test.+/
      inTest = true
      indentCount += 1
    when /{/
      indentCount += 1
    when /var (?<variable>.+) = assert.async/

      if (inTest)
        variableNames.push($~[:variable])
      end

    when /assert\.strictEqual/
      inTest = false
    when /assert\.deepEqual/
      inTest = false
    when /assert\.ok/
      inTest = false
    when /\ +(?<method>.+)\(\)/

      if (!inTest)

        for variable in variableNames

          if variable.eql?($~[:method])
            variableNames.delete(variable)
          end
        end
      else
        for variable in variableNames
          if (variable.eql?($~[:method]))
            lines.delete_at(curLine)
            curLine -= 1
          end
        end
      end
    when /}\);/
      inserted = false

      while (!variableNames.empty?)
        indent = "\t" * indentCount
        lines.insert(curLine, indent + variableNames.pop + "()")
        curLine += 1
      end

      indentCount -= 1

    when /}/
      indentCount -= 1
    end
    curLine += 1
  end
  puts lines
end
