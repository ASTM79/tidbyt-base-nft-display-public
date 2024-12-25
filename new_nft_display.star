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
        "pageSize": "1000"
    }
    
    response = http.get(url = url, params = params)
    data = response.json()
    nfts = data.get("ownedNfts", [])
    print("Total NFTs found:", len(nfts))
    return nfts

def get_image_url(nft):
    if "media" in nft and nft["media"]:
        if len(nft["media"]) > 0:
            url = nft["media"][0].get("gateway", "")
            # Skip SVG images as they're not well supported
            if url.lower().endswith(".svg"):
                return None
            return url
    return None

def fetch_image_with_timeout(url, timeout = 3):
    try:
        response = http.get(url, ttl_seconds = timeout)
        if response.status_code == 200:
            # Check for common image formats
            data = response.body()
            if len(data) < 8:  # Basic validation
                return None
                
            # Check file signature/magic numbers
            if data.startswith(b"\x89PNG") or \
               data.startswith(b"\xFF\xD8\xFF") or \
               data.startswith(b"GIF"):
                return data
            
            print("Unsupported image format for URL:", url)
            return None
            
    except Exception as e:
        print("Error fetching image:", str(e))
        return None
        
    return None

def get_nft_display(nft):
    image_url = get_image_url(nft)
    title = nft.get("title", "")[:6]
    
    if not image_url:
        return render.Box(
            width = 28,
            height = 32,
            child = render.Column(
                expanded = True,
                main_align = "center",
                children = [
                    render.Text(title, font = "tom-thumb"),
                    render.Text("No img", font = "tom-thumb")
                ]
            )
        )

    image_data = fetch_image_with_timeout(image_url)
    if not image_data:
        return render.Box(
            width = 28,
            height = 32,
            child = render.Column(
                expanded = True,
                main_align = "center",
                children = [
                    render.Text(title, font = "tom-thumb"),
                    render.Text("Load...", font = "tom-thumb")
                ]
            )
        )

    return render.Column(
        expanded = True,
        main_align = "center",
        cross_align = "center",
        children = [
            render.Image(
                src = image_data,
                width = 28,
                height = 28
            ),
            render.Text(title, font = "tom-thumb")
        ]
    )

def main():
    nfts = get_nfts()
    nft_count = len(nfts)
    print("NFTs available for display:", nft_count)
    
    if not nfts:
        return render.Root(
            child = render.Text("No NFTs found")
        )
    
    current_time = time.now().unix
    first_index = int(current_time / 5) % nft_count
    second_index = (first_index + 1) % nft_count
    
    print("Displaying NFTs at indices:", first_index, second_index)
    
    return render.Root(
        child = render.Row(
            expanded = True,
            main_align = "space_between",
            children = [
                get_nft_display(nfts[first_index]),
                render.Box(
                    width = 1,
                    height = 32,
                    color = "#333"
                ),
                get_nft_display(nfts[second_index])
            ]
        )
    )