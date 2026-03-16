#!/bin/sh

echo "==== INSTA STALKER V2 ===="

printf "Cole o link ou @ do perfil: "
read input

insta_user=$(echo "$input" | sed 's/https:\/\/www.instagram.com\///' | sed 's/@//' | cut -d'?' -f1 | cut -d'/' -f1)

profile_url="https://www.instagram.com/$insta_user/"

echo "[*] Verificando perfil..."
html=$(curl -s -A "Mozilla/5.0" "$profile_url")

if echo "$html" | grep -qi "private"; then
echo "[!] Perfil privado ou inexistente."
exit 1
fi

echo "[OK] Perfil público encontrado!"

echo ""
echo "==== INFO DO PERFIL ===="

bio=$(echo "$html" | grep -o '"biography":"[^"]*' | head -n1 | cut -d'"' -f4)
echo "Bio: $bio"

followers=$(echo "$html" | grep -o '"edge_followed_by":{"count":[0-9]*' | grep -o '[0-9]*')
echo "Seguidores: $followers"

following=$(echo "$html" | grep -o '"edge_follow":{"count":[0-9]*' | grep -o '[0-9]*')
echo "Seguindo: $following"

echo ""
echo "==== BUSCANDO MENÇÕES ===="

search="site:instagram.com \"$insta_user\""
url="https://www.google.com/search?q=$(echo $search | sed 's/ /+/g')"

results=$(curl -s -A "Mozilla/5.0" "$url")

echo "$results" \
| grep -o -E 'instagram.com/[a-zA-Z0-9_.]+' \
| grep -v "$insta_user" \
| awk -F/ '{print "@"$2}' \
| sort \
| uniq

echo ""
echo "==== FIM ===="
