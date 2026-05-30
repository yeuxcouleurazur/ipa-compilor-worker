import os
import urllib.request
import json
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

tokens = {
    "bitcoin": "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
    "ethereum": "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
    "solana": "https://assets.coingecko.com/coins/images/4128/large/solana.png",
    "usdc": "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png",
    "monad": "https://pbs.twimg.com/profile_images/1625902035252875266/bLg3D7X4_400x400.jpg",
    "chillguy": "https://assets.coingecko.com/coins/images/36209/large/chillguy.jpeg",
    "goat": "https://assets.coingecko.com/coins/images/35882/large/goat.png",
    "zerebro": "https://assets.coingecko.com/coins/images/36021/large/zerebro.png",
    "wif": "https://assets.coingecko.com/coins/images/33566/large/dogwifhat.jpg",
    "bonk": "https://assets.coingecko.com/coins/images/28600/large/bonk.jpg",
    "popcat": "https://assets.coingecko.com/coins/images/28741/large/popcat.png",
    "pnut": "https://assets.coingecko.com/coins/images/32585/large/pnut.png",
    "fwog": "https://assets.coingecko.com/coins/images/35161/large/fwog.png",
    "mew": "https://assets.coingecko.com/coins/images/35071/large/mew.png"
}

assets_dir = "Assets.xcassets"
os.makedirs(assets_dir, exist_ok=True)

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

for name, url in tokens.items():
    print(f"Downloading {name}...")
    imageset_dir = os.path.join(assets_dir, f"{name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    ext = url.split('.')[-1]
    if ext not in ['png', 'jpg', 'jpeg']:
        ext = 'png'
        
    filename = f"{name}.{ext}"
    filepath = os.path.join(imageset_dir, filename)
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response, open(filepath, 'wb') as out_file:
            out_file.write(response.read())
            
        # Write Contents.json
        contents = {
            "images": [
                {
                    "filename": filename,
                    "idiom": "universal",
                    "scale": "1x"
                },
                {
                    "idiom": "universal",
                    "scale": "2x"
                },
                {
                    "idiom": "universal",
                    "scale": "3x"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
        with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
            json.dump(contents, f, indent=2)
            
        print(f"Success: {name}")
    except Exception as e:
        print(f"Error downloading {name}: {e}")

print("Done.")
