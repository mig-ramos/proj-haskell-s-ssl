git add . &&
git commit -m "$1" &&
git push origin master &&
ssh root@144.217.86.54 <<EOF
cd eletronica-universal &&
git pull origin master &&
stack build &&
lsof -i:8080 -Fp | sed 's/^p//' | head -n -1 | xargs kill -9;
nohup stack exec eletronica-universal > /dev/nul
echo "deploy finished"
EOF
