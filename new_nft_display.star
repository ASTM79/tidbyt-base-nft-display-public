load("render.star", "render")
load("http.star", "http")
load("time.star", "time")

WALLET_ADDRESS = "0xBf57c94BDD49e10356F7a4F3AFaC8E675425a161"
ALCHEMY_API_KEY = "6nb4oIj2MMnVZmQRsG1lpS5OiiNVhWBp"
BASE_ALCHEMY_URL = "https://base-mainnet.g.alchemy.com/v2/"

# Display constants optimized for Tidbyt
DISPLAY_WIDTH = 64
DISPLAY_HEIGHT = 32
IMAGE_PADDING = 2

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

def render_nft_display(image_data, title=None):
    # Calculate optimal image size while maintaining aspect ratio
    image_height = DISPLAY_HEIGHT - (IMAGE_PADDING * 2)
    image_width = image_height  # Keep it square for NFTs
    
    # Center the image horizontally
    x_offset = (DISPLAY_WIDTH - image_width) // 2
    
    display_elements = [
        render.Padding(
            pad=(x_offset, IMAGE_PADDING, x_offset, IMAGE_PADDING),
            child=render.Image(
                src=image_data,
                width=image_width,
                height=image_height,
                fit="contain"  # Maintain aspect ratio
            )
        )
    ]
    
    if title:
        display_elements.append(
            render.Padding(
                pad=(0, 1, 0, 0),
                child=render.Text(
                    content=title,
                    font="tom-thumb",  # Smallest font for maximum clarity
                    color="#fff"
                )
            )
        )
    
    return render.Root(
        child=render.Box(
            width=DISPLAY_WIDTH,
            height=DISPLAY_HEIGHT,
            child=render.Column(
                expanded=True,
                main_align="center",
                cross_align="center",
                children=display_elements
            )
        )
    )

def main():
    nfts = get_nfts()
    
    if not nfts:
        return render.Root(
            child=render.Text("No NFTs found")
        )
    
    current_time = time.now().unix
    nft_index = int(current_time / 5) % len(nfts)
    current_nft = nfts[nft_index]
    
    image_url = get_image_url(current_nft)
    
    if image_url:
        response = http.get(image_url)
        if response.status_code == 200:
            # Get NFT title if available
            title = current_nft.get("title", "")
            if len(title) > 10:  # Truncate long titles
                title = title[:8] + "..."
            
            return render_nft_display(
                image_data=response.body(),
                title=title
            )
    
    return render.Root(
        child=render.Text("No Image")
    )