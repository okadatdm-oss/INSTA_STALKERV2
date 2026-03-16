#!/bin/sh

echo "==== INSTA STALKER V2 ===="

printf "Cole o link ou @ do perfil: "
read input

# limpa link ou @
insta_user=$(echo "$input" \
| sed 's/https:\/\/www.instagram.com\///' \
| sed 's/@//' \
| cut -d'?' -f1 \
| cut -d'/' -f1)

profile_url="https://www.instagram.com/$insta_user/"

echo "[*] Acessando perfil..."

html=$(curl -s \
-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36" \
"$profile_url")

# perfil inexistente
if echo "$html" | grep -q "Page Not Found"; then
echo "[!] Perfil não encontrado."
exit 1
fi

# perfil privado
if echo "$html" | grep -q '"is_private":true'; then
echo "[!] Perfil privado."
exit 1
fi

echo "[OK] Perfil público encontrado!"

echo ""
echo "===== INFORMAÇÕES ====="

bio=$(echo "$html" \
| grep -o '"biography":"[^"]*' \
| head -n1 \
| cut -d'"' -f4)

followers=$(echo "$html" \
| grep -o '"edge_followed_by":{"count":[0-9]*' \
| grep -o '[0-9]*')

following=$(echo "$html" \
| grep -o '"edge_follow":{"count":[0-9]*' \
| grep -o '[0-9]*')

posts=$(echo "$html" \
| grep -o '"edge_owner_to_timeline_media":{"count":[0-9]*' \
| grep -o '[0-9]*')

echo "Usuário: @$insta_user"
echo "Bio: $bio"
echo "Posts: $posts"
echo "Seguidores: $followers"
echo "Seguindo: $following"

echo ""
echo "===== BUSCANDO MENÇÕES ====="

query="site:instagram.com \"$insta_user\""

search_url="https://www.google.com/search?q=$(echo $query | sed 's/ /+/g')"

results=$(curl -s \
-A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
"$search_url")

echo "$results" \
| grep -o -E 'instagram.com/[a-zA-Z0-9_.]+' \
| grep -v "$insta_user" \
| awk -F/ '{print "@"$2}' \
| sort \
| uniq

echo ""
echo "==== FIM ===="
