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

def get_nft_details(nft):
    title = nft.get("title", "Unnamed NFT")
    collection = nft.get("contract", {}).get("name", "Unknown Collection")
    return title, collection

def main():
    nfts = get_nfts()
    
    if not nfts:
        return render.Root(
            child = render.Column(
                main_align="center",
                cross_align="center",
                expanded=True,
                children = [
                    render.Text("No NFTs found", color="#FF0000"),
                    render.Text(WALLET_ADDRESS[:8] + "...", color="#666666"),
                ]
            )
        )
    
    current_time = time.now().unix
    nft_index = int(current_time / 5) % len(nfts)
    current_nft = nfts[nft_index]
    
    title, collection = get_nft_details(current_nft)
    image_url = get_image_url(current_nft)
    
    display_children = [
        render.Text(
            "%d/%d" % (nft_index + 1, len(nfts)),
            font="6x13",
            color="#00FF00"
        )
    ]
    
    if image_url:
        try:
            response = http.get(image_url)
            if response.status_code == 200:
                display_children.extend([
                    render.Image(
                        src = response.body(),
                        width = 32,
                        height = 32
                    ),
                ])
        except:
            pass
    
    # Always show title and collection, even if image fails
    display_children.extend([
        render.Marquee(
            width = 64,
            child = render.Text(title, color="#FFFFFF")
        ),
        render.Marquee(
            width = 64,
            child = render.Text(collection, color="#888888")
        )
    ])
    
    return render.Root(
        child = render.Column(
            main_align = "center",
            cross_align = "center",
            expanded = True,
            children = display_children
        )
    )