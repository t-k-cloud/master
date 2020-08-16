#!/bin/bash

if tmux has-session -t tkcloud 2> /dev/null; then
	# To kill existing session
	tmux kill-session -t 'tkcloud'
fi

tmux new-session -c ~/master-tree/proj/tkcloud -s 'tkcloud' -d

for i in {1..6}; do
	tmux split-window -t tkcloud -c "#{pane_current_path}"
	tmux select-layout -t tkcloud tiled
done

for i in {0..6}; do
	tmux select-pane -t tkcloud.${i}
	case "$i" in
		0)
		tmux send-keys -t tkcloud "cd client/useful-scripts"
		tmux send-keys -t tkcloud Enter
		tmux send-keys -t tkcloud "./gfw.sh"
		tmux send-keys -t tkcloud Enter
		;;

		1)
		tmux send-keys -t tkcloud "cd client/useful-scripts"
		tmux send-keys -t tkcloud Enter
		tmux send-keys -t tkcloud "./show-cpu-temp.sh"
		tmux send-keys -t tkcloud Enter
		;;

		2)
		tmux send-keys -t tkcloud "cd auth"
		tmux send-keys -t tkcloud Enter
		tmux send-keys -t tkcloud "node authd.js"
		tmux send-keys -t tkcloud Enter
		;;

		3)
		tmux send-keys -t tkcloud "cd jobd"
		tmux send-keys -t tkcloud Enter
		tmux send-keys -t tkcloud "sudo node jobd.js `whoami` ../master/jobs/"
		tmux send-keys -t tkcloud Enter
		;;

		4)
		tmux send-keys -t tkcloud "cd ../doudou"
		tmux send-keys -t tkcloud Enter
		tmux send-keys -t tkcloud "node httpd.js"
		tmux send-keys -t tkcloud Enter
		;;

		5)
		tmux send-keys -t tkcloud "cd ../doudou"
		tmux send-keys -t tkcloud Enter
		tmux send-keys -t tkcloud "python doudou.py --searchd --indexd"
		tmux send-keys -t tkcloud Enter
		;;

		6)
		tmux send-keys -t tkcloud "top"
		tmux send-keys -t tkcloud Enter
		tmux select-pane -t tkcloud.3 # focus on jobd pane
		;;
	esac
done
