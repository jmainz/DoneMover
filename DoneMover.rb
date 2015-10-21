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
