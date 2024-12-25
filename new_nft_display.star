load("render.star", "render")
load("http.star", "http")
load("time.star", "time")

WALLET_ADDRESS = "0xBf57c94BDD49e10356F7a4F3AFaC8E675425a161"
ALCHEMY_API_KEY = "6nb4oIj2MMnVZmQRsG1lpS5OiiNVhWBp"
BASE_ALCHEMY_URL = "https://base-mainnet.g.alchemy.com/v2/"

def get_nfts():
    url = BASE_ALCHEMY_URL + ALCHEMY_API_KEY + "/getNFTs"
    params = {
        "owner": WALLET_ADDRESS,
        "withMetadata": "true",
        "pageSize": "100"
    }
    response = http.get(url = url, params = params)
    return response.json().get("ownedNfts", [])

def get_image_url(nft):
    if "media" in nft and nft["media"]:
        if len(nft["media"]) > 0:
            return nft["media"][0].get("gateway", "")
    return None

def main():
    nfts = get_nfts()
    
    if not nfts:
        return render.Root(
            child = render.Text("No NFTs found")
        )
    
    current_time = time.now().unix
    nft_index = int(current_time / 5) % len(nfts)  # Changed to 5 second rotation
    current_nft = nfts[nft_index]
    
    image_url = get_image_url(current_nft)
    
    if image_url:
        response = http.get(image_url)
        if response.status_code == 200:
            return render.Root(
                child = render.Box(
                    width = 64,
                    height = 32,
                    child = render.Image(
                        src = response.body(),
                        width = 32,
                        height = 32
                    )
                )
            )
    
    return render.Root(
        child = render.Text("No Image")
    )