#require 'json'

begin
	project_vars = ARGV
	local_project_vars = []
	project_vars_hash = {}

	loop { case project_vars[0]
	    when '--location' then project_vars.shift; project_vars_hash[:location] = project_vars.shift
	    when '--regex' then project_vars.shift; project_vars_hash[:regex] = project_vars.shift
			else break
	end; }

	local_project_vars = project_vars_hash
	Dir.chdir local_project_vars[:location]
	#STDOUT.puts Dir.glob(@@project_vars[:regex]).to_json
	STDOUT.puts Dir.glob(local_project_vars[:regex]).join(",")
rescue => ex
  STDERR.puts ex.message
end