import urllib.request
import json
import os

titles = {
    'pdam': 'File:Logo_pdam.jpg',
    'indihome': 'File:IndiHome_logo.svg',
    'bpjs': 'File:Logo_BPJS_Kesehatan.svg'
}

headers = {'User-Agent': 'Mozilla/5.0'}

for name, title in titles.items():
    url = f"https://id.wikipedia.org/w/api.php?action=query&titles={title}&prop=imageinfo&iiprop=url&iiurlwidth=128&format=json"
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            pages = data['query']['pages']
            for page_id in pages:
                if page_id == '-1':
                    # Maybe it's on commons!
                    url2 = f"https://commons.wikimedia.org/w/api.php?action=query&titles={title}&prop=imageinfo&iiprop=url&iiurlwidth=128&format=json"
                    req2 = urllib.request.Request(url2, headers=headers)
                    with urllib.request.urlopen(req2) as resp2:
                        data2 = json.loads(resp2.read())
                        pages2 = data2['query']['pages']
                        for p2 in pages2:
                            image_info = pages2[p2].get('imageinfo', [{}])[0]
                            image_url = image_info.get('thumburl')
                            if image_url:
                                print(f"{name} (commons): {image_url}")
                                img_req = urllib.request.Request(image_url, headers=headers)
                                with urllib.request.urlopen(img_req) as img_resp:
                                    with open(f"assets/logos/{name}.png", "wb") as f:
                                        f.write(img_resp.read())
                else:
                    image_info = pages[page_id].get('imageinfo', [{}])[0]
                    image_url = image_info.get('thumburl')
                    if image_url:
                        print(f"{name}: {image_url}")
                        img_req = urllib.request.Request(image_url, headers=headers)
                        with urllib.request.urlopen(img_req) as img_resp:
                            with open(f"assets/logos/{name}.png", "wb") as f:
                                f.write(img_resp.read())
    except Exception as e:
        print(f"Failed {name}: {e}")
