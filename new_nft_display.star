load("render.star", "render")
load("http.star", "http")
load("time.star", "time")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("cache.star", "cache")

WALLET_ADDRESS = "0xBf57c94BDD49e10356F7a4F3AFaC8E675425a161"
ALCHEMY_API_KEY = "6nb4oIj2MMnVZmQRsG1lpS5OiiNVhWBp"
BASE_ALCHEMY_URL = "https://base-mainnet.g.alchemy.com/v2/"

# Cache keys
CACHE_KEY_NFTS = "nfts"
CACHE_TTL = 300  # 5 minutes cache

def display_error(message, details = None):
    """Renders an error message in a visually appealing way."""
    color = "#ff0000"
    return render.Root(
        child = render.Box(
            child = render.Column(
                expanded = True,
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Text("Error!", color = color),
                    render.Text(message, font = "tom-thumb"),
                    render.Text(str(details)[:20], font = "tom-thumb") if details else None,
                ],
            ),
        ),
    )

def fetch_with_retry(url, params, max_retries = 3, initial_delay = 1):
    """Fetches data with exponential backoff retry logic."""
    delay = initial_delay
    
    for attempt in range(max_retries):
        try:
            response = http.get(url = url, params = params)
            
            if response.status_code == 200:
                return response.json()
            elif response.status_code == 429:  # Rate limit
                if attempt < max_retries - 1:
                    time.sleep(delay)
                    delay *= 2
                    continue
                else:
                    return {"error": "Rate limited", "details": response.body()}
            elif response.status_code >= 500:
                if attempt < max_retries - 1:
                    time.sleep(delay)
                    delay *= 2
                    continue
                else:
                    return {"error": "Server error", "details": response.status_code}
            else:
                return {"error": "HTTP error", "details": response.status_code}
                
        except Exception as e:
            if attempt < max_retries - 1:
                time.sleep(delay)
                delay *= 2
                continue
            return {"error": "Network error", "details": str(e)}
    
    return {"error": "Max retries exceeded"}

def get_nfts():
    """Fetches NFTs with caching and error handling."""
    # Check cache first
    cached = cache.get(CACHE_KEY_NFTS)
    if cached != None:
        return base64.decode(cached)
    
    url = BASE_ALCHEMY_URL + ALCHEMY_API_KEY + "/getNFTs"
    params = {
        "owner": WALLET_ADDRESS,
        "withMetadata": "true",
        "pageSize": "100"
    }
    
    result = fetch_with_retry(url, params)
    
    if "error" in result:
        return result
        
    # Cache successful results
    cache.set(
        CACHE_KEY_NFTS,
        base64.encode(result.get("ownedNfts", [])),
        ttl_seconds = CACHE_TTL,
    )
    
    return result.get("ownedNfts", [])

def get_image_url(nft):
    """Safely extracts image URL from NFT metadata."""
    try:
        if "media" in nft and nft["media"]:
            if len(nft["media"]) > 0:
                return nft["media"][0].get("gateway", "")
    except Exception as e:
        return None
    return None

def fetch_image(url):
    """Fetches image with error handling."""
    try:
        response = http.get(url)
        if response.status_code == 200:
            return response.body()
        else:
            return None
    except Exception as e:
        return None

def main():
    nfts = get_nfts()
    
    # Handle NFT fetch errors
    if isinstance(nfts, dict) and "error" in nfts:
        return display_error(nfts["error"], nfts.get("details"))
    
    if not nfts:
        return render.Root(
            child = render.Column(
                expanded = True,
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Text("No NFTs found"),
                    render.Text("Check wallet", font = "tom-thumb"),
                ],
            ),
        )
    
    current_time = time.now().unix
    nft_index = int(current_time / 5) % len(nfts)
    
    try:
        current_nft = nfts[nft_index]
    except Exception as e:
        return display_error("NFT access error")
    
    image_url = get_image_url(current_nft)
    
    if not image_url:
        return render.Root(
            child = render.Column(
                expanded = True,
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Text("No Image"),
                    render.Text("URL Error", font = "tom-thumb"),
                ],
            ),
        )
    
    image_data = fetch_image(image_url)
    
    if not image_data:
        return render.Root(
            child = render.Column(
                expanded = True,
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Text("Load Error"),
                    render.Text("Image Failed", font = "tom-thumb"),
                ],
            ),
        )
    
    try:
        return render.Root(
            child = render.Box(
                width = 64,
                height = 32,
                child = render.Image(
                    src = image_data,
                    width = 32,
                    height = 32,
                )
            )
        )
    except Exception as e:
        return display_error("Display Error")