#!/usr/bin/env ruby

last_md5 = ''

build_cmd = "haxe build.hxml -debug -D source-map-content"
run_cmd = "cd bin && node --inspect boot.js"
run_pid = nil

first = "google-chrome --new-window debug.html 1>/dev/null 2>&1 &"

puts "Watching..."
while true
  md5 = `(find . -type f) | grep -v ./bin/ | grep -v '#' | xargs md5sum | md5sum`.chomp.sub(/ .*/,'')
  if (md5!=last_md5) then
    last_md5 = md5
    t0 = Time.now.to_f
    puts ""
    puts "---------------------------------------------------------"
    puts "Build [#{ md5 }] ..."
    puts "---------------------------------------------------------"
    puts `#{ build_cmd }`
    build_success = ($?==0) # last exit code
    puts "Finished #{ Time.now.to_f-t0 } sec"
    puts "---------------------------------------------------------"

    # Kill last running nodejs
    if (run_pid!=nil) then
      puts "Killing existing nodejs server thread #{ run_pid }"
      `ps -aef | grep -i node | grep -i inspect | grep -v grep | awk '{print $2}' | xargs kill -9`

      # This didn't work...
      #`kill -9 #{ run_pid }` rescue nil

      `sleep 0.1`
      run_pid = nil
    end

    # If build was successful, launch nodejs
    if (build_success) then
      run_pid = fork do
        puts "Launching nodejs server thread..."
        system(run_cmd)
        puts "Nodejs server thread exited..."
        exit(0)
      end
      Process.detach(run_pid)
    end

  end
  `sleep 0.5`
  
  if (first!=nil) then
    puts "Launching browsers at: chrome://inspect and http://127.0.0.1:8000"
    `#{ first }`
    first = nil
  end
end
