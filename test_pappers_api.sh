#!/bin/bash
API_KEY="b547834779efefb362b2d7fb2ffeafb3d1e4826acc0e85fd"
SIREN="888207859"
echo "Appel API Pappers pour SIREN: $SIREN"
curl -s "https://api.pappers.fr/v2/entreprise?api_token=$API_KEY&siren=$SIREN" | jq '.'
