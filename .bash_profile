#___Recon___

certprobe(){ #runs httprobe on all the hosts from certspotter
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe | tee -a ./all.txt
}


#___Tools___

dirsearch(){
python3 ~/tools/dirsearch/dirsearch.py -u $1 -e html, js, php -t 20 -w ~/tools/SecLists/Discovery/Web-Content/raft-small-words.txt -b
}

fuff(){
ffuf -w ~/tools/Seclists/Discovery/Web-Content/raft-small-words.txt -u $1 -mc 200,302,403 -c -t 50
}

auto(){
sudo ~/tools/Recon/./auto.sh $1 
}

linkfinder(){
python3 ~/tools/LinkFinder/linkfinder.py -i $1 -d -o cli
}
