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
        "pageSize": "1000"  # Increased page size to maximum
    }
    
    response = http.get(url = url, params = params)
    return response.json().get("ownedNfts", [])

def get_image_url(nft):
    if "media" in nft and nft["media"]:
        if len(nft["media"]) > 0:
            return nft["media"][0].get("gateway", "")
    return None

def get_nft_display(nft):
    image_url = get_image_url(nft)
    title = nft.get("title", "")[:6]
    
    if image_url:
        response = http.get(image_url)
        if response.status_code == 200:
            return render.Column(
                expanded = True,
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Image(
                        src = response.body(),
                        width = 28,
                        height = 28
                    ),
                    render.Text(title, font = "tom-thumb")
                ]
            )
    return render.Text("No Image")

def main():
    nfts = get_nfts()
    
    if not nfts:
        return render.Root(
            child = render.Text("No NFTs found")
        )
    
    current_time = time.now().unix
    first_index = int(current_time / 5) % len(nfts)
    second_index = (first_index + 1) % len(nfts)
    
    first_nft = nfts[first_index]
    second_nft = nfts[second_index]
    
    return render.Root(
        child = render.Row(
            expanded = True,
            main_align = "space_between",
            children = [
                get_nft_display(first_nft),
                render.Box(
                    width = 1,
                    height = 32,
                    color = "#333"
                ),
                get_nft_display(second_nft)
            ]
        )
    )