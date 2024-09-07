import os
from PIL import Image
import fitz
import io

SUPPORTED_DOCUMENTS_TYPES = ["pdf", "docx"]

def extract_document(file_path:str, extract_images = False)->dict:
    ''' Extracts texts, tables and images from a pdf document'''
    data = {
        'texts':[],
        'tables':[],
        'images':[],
    }

    print("started extracting of doc")

    save_path = os.path.join(os.getcwd(),"media")
    filename = file_path.split('/')[-1].split('.')[0]
    file_extension = file_path.split('.')[-1]

    # Check Supported Files
    if not file_extension in SUPPORTED_DOCUMENTS_TYPES:
        print(f"FILE FORMAT NOT SUPPORTED ({file_extension})")
        return data

    pdf_file = fitz.open(file_path)
    file_id = 0

    print("starting loop for pages")

    # iterate over PDF pages
    for page_index in range(len(pdf_file)):

        # get the page itself
        page = pdf_file[page_index]
        image_list = page.get_images()

        print(page_index)

        if extract_images:
            # FIND IMAGES
            if not 'media' in os.listdir("./"):
                os.mkdir(os.path.join(save_path, 'media'))
            if not 'imgs' in os.listdir(save_path):
                os.mkdir(os.path.join(save_path, 'imgs'))

            for image_index, img in enumerate(page.get_images(full=True), start=1):
                try:
                    pix1 = fitz.Pixmap(pdf_file.extract_image(img[0])["image"])
                    mask = fitz.Pixmap(pdf_file.extract_image(img[1])["image"])
                    pix = fitz.Pixmap(pix1, mask)
                    im = Image.open(io.BytesIO(pix.tobytes()))
                except:
                    pix = pdf_file.extract_image(img[0])["image"]
                    im = Image.open(io.BytesIO(pix))

                # Save Images
                img_path = os.path.join(save_path,f"imgs/{page_index}_{file_id}.png")
                im.save(img_path)

                data['images'].append(img_path)
                file_id+=1

        # FIND TABLES
        tabs = page.find_tables()
        if tabs.tables:
            table = tabs[0].extract()
            data['tables'].append({'table':table,'page_no':page_index})


        # FIND TEXTS
        data['texts'].append({'text':page.get_text(),'page_no':page_index})

    print(f"Found {len(data['texts'])} page(s), {len(data['images'])} image(s) and {len(data['tables'])} table(s).")
    return data      # To verify if the document was read successfully   