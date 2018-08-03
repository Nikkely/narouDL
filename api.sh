curl https://api.syosetu.com/novel18api/api/?lim=20\&out=json\&word=エロ \
| jq '.[] | {"ncode": .ncode, "num": .general_all_no }' | sed '1,4d' > target.json
