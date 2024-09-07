import requests
import os
import time
import json
import base64

from PyPDF2 import PdfReader
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv,dotenv_values
from msal import ConfidentialClientApplication
from azure.identity import ClientSecretCredential


def download_file_from_sharepoint(url:str):
    """Download a file from SharePoint link."""
    # Get the SharePoint token
    access_token = get_sharepoint_token()

    # Use the access token to resolve the sharing link
    headers = {'Authorization': f"Bearer {access_token}"}

    # Encode the sharing link
    encoded_link = base64.urlsafe_b64encode(url.encode('utf-8')).decode('utf-8').rstrip('=')

    # Construct the API URL to resolve the sharing link
    resolve_url = f'https://graph.microsoft.com/v1.0/shares/u!{encoded_link}/driveItem'
    response = requests.get(resolve_url, headers=headers)

    if response.status_code == 200:
        drive_item = response.json()
        
        # Retrieve the download URL and file name
        download_url = drive_item.get('@microsoft.graph.downloadUrl')
        file_name = drive_item.get('name')  # Extract the file name
        
        if download_url and file_name:
            # Download the file using the download URL
            file_response = requests.get(download_url)

            if file_response.status_code == 200:
                # Save the file with the correct name and extension
                if os.path.exists("downloads"):
                    pass
                else:
                    os.makedirs("downloads")
                with open(f"downloads/{file_name}", 'wb') as file:
                    file.write(file_response.content)

                print(f"File '{file_name}' downloaded successfully.")
                return f"downloads/{file_name}"
            else:
                print(f"Failed to download file: {file_response.status_code} - {file_response.text}")
        else:
            print("Could not retrieve download URL or file name.")
    else:
        print(f"Failed to resolve sharing link: {response.status_code} - {response.text}")

def download_file_from_sharepoint_item_id(item_id:str, allowed_extensions:list=["docx"]):
    """Download a file from SharePoint folder id."""
    # Get the SharePoint token
    access_token = get_sharepoint_token()

    # Use the access token to resolve the sharing link
    headers = {'Authorization': f"Bearer {access_token}"}

    group_id = get_all_groups()['Georgiou Group x Insurgence']
    endpoint = f'https://graph.microsoft.com/v1.0/groups/{group_id}/drive/items/{item_id}'
    
    response = requests.get(endpoint, headers=headers)
    if response.status_code == 200:
        download_url = response.json()['@microsoft.graph.downloadUrl']
        file_name = response.json()['name']
        file_data = requests.get(download_url)

        file_extension = file_name.split('.')[-1].lower()
        if file_extension in allowed_extensions:
            file_path = store_in_temp_file(file_data.content, file_name)
            print(f"Return: {file_path}")
            return (file_path,file_name)
        else:
            return ("","")
    else:
        print(f"Failed to download file: {response.status_code}\n\nFolder ID: {item_id}")
        print(response.json())
        return ("","")
    
def store_in_temp_file(data, file_name:str):
    if "downloads" not in os.listdir():
        os.mkdir("downloads")
    file_path = os.path.join("downloads",file_name)

    with open(file_path,"wb") as f:
        f.write(data)
    return file_path

def get_sharepoint_token()->str:
    """Get a SharePoint token for the current user."""
    app = ConfidentialClientApplication(
        os.getenv('CLIENT_ID'),
        authority=f"https://login.microsoftonline.com/{os.getenv('MICROSOFT_APP_TENANT_ID')}",
        client_credential=os.getenv('CLIENT_SECRET'),
    )

    # Acquire a token from Azure AD
    result = app.acquire_token_for_client(scopes=["https://graph.microsoft.com/.default"])
    return result['access_token']

def get_folder_id(url:str)->str:
    """Download a file from SharePoint link."""
    # Get the SharePoint token
    access_token = get_sharepoint_token()
    # Use the access token to resolve the sharing link
    headers = {'Authorization': f"Bearer {access_token}"}

    # Encode the sharing link
    encoded_link = base64.urlsafe_b64encode(url.encode('utf-8')).decode('utf-8').rstrip('=')

    # Construct the API URL to resolve the sharing link
    resolve_url = f'https://graph.microsoft.com/v1.0/shares/u!{encoded_link}/driveItem'
    response = requests.get(resolve_url, headers=headers)

    return response.json()['id']

def list_items_in_folder(folder_url:str, group_name:str="Georgiou Group x Insurgence")->dict:
    group_id = get_all_groups()[group_name]
    folder_id = get_folder_id(folder_url)
    access_token = get_sharepoint_token()
    
    endpoint = f'https://graph.microsoft.com/v1.0/groups/{group_id}/drive/items/{folder_id}/children'
    folders = {}

    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    response = requests.get(endpoint, headers=headers)
    if response.status_code == 200:
        folder_result = response.json()
    else:
        print(f"Failed to list files: {response.status_code}")
        print(response.json())

    folders = {}
    for val in folder_result['value']:
        folders[val["name"]] = val["id"]

    return folders

def upload_file_to_sharepoint(file_path:str,folder_url:str="")->str:
    filename = os.path.basename(file_path)
    parent_id = get_item_id(folder_url)

    # Read the contents of the Excel file in binary mode
    with open(file_path, 'rb') as file:
        file_content = file.read()

    # Azure Credentials
    client_id=os.getenv("CLIENT_ID")
    client_secret=os.getenv("CLIENT_SECRET")
    tenant_id=os.getenv("MICROSOFT_APP_TENANT_ID")

    credentials = ClientSecretCredential(
        client_id=client_id,
        client_secret=client_secret,
        tenant_id=tenant_id
    )
    scopes = ["https://graph.microsoft.com/.default"]
    access_token = credentials.get_token(*scopes)

    headers = {
        "Authorization": f"Bearer {access_token.token}",
        "Content-Type": "application/octet-stream",
    }

    # Site ID for 'ARA Group' Site
    site_id = "fifthstreet791.sharepoint.com,863d8c81-76fa-4e6d-ba12-5f9017bfac4a,55950251-6504-4a73-a7d6-2b6c42eefb5d"
    endpoint = f'https://graph.microsoft.com/v1.0/sites/{site_id}/drive/items/{parent_id}:/{filename}:/content'

    # Make the request to upload the file content
    response = requests.put(
        url=endpoint,
        headers=headers,
        data=file_content,
    )

    print(response.status_code)
    if response.status_code == 201 or response.status_code == 200:
        print("File uploaded successfully!")
        return response.json()['webUrl']
    else:
        # Print the response in JSON format
        print(json.dumps(response.json(), indent=4))
        raise Exception("An error occured while uploading the file to sharepoint")
    
def get_all_groups()->dict:
    """Get all the groups and their ids from the Insurgence sharepoint tenant"""
    client_id=os.getenv("CLIENT_ID")
    client_secret=os.getenv("CLIENT_SECRET")
    tenant_id=os.getenv("MICROSOFT_APP_TENANT_ID")

    credentials = ClientSecretCredential(
    client_id=client_id,
    client_secret=client_secret,
    tenant_id=tenant_id
    )
    scopes = ["https://graph.microsoft.com/.default"]
    access_token = credentials.get_token(*scopes)

    groups = {}
    endpoint = f'https://graph.microsoft.com/v1.0/groups'

    headers = {
        'Authorization': f'Bearer {access_token.token}'
    }
    response = requests.get(endpoint, headers=headers)
    if response.status_code == 200:
        result = response.json()
    else:
        print(f"Failed to retrieve data: {response.status_code}")

    result = response.json()
    for val in result['value']:
        groups[val["displayName"]] = val["id"]

    return groups

def get_item_id(url:str):
    # Get the SharePoint token
    access_token = get_sharepoint_token()
 
    # Use the access token to resolve the sharing link
    headers = {'Authorization': f"Bearer {access_token}"}
 
    # Encode the sharing link
    encoded_link = base64.urlsafe_b64encode(url.encode('utf-8')).decode('utf-8').rstrip('=')
 
    # Construct the API URL to resolve the sharing link
    resolve_url = f'https://graph.microsoft.com/v1.0/shares/u!{encoded_link}/driveItem'
    response = requests.get(resolve_url, headers=headers)
    item_id = response.json()['id']
 
    return item_id

def list_items_in_folder(folder_url:str, group_name:str="Georgiou Group x Insurgence")->dict:
    group_id = get_all_groups()[group_name]
    folder_id = get_item_id(folder_url)
    access_token = get_sharepoint_token()
    
    endpoint = f'https://graph.microsoft.com/v1.0/groups/{group_id}/drive/items/{folder_id}/children'
    folders = {}

    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    response = requests.get(endpoint, headers=headers)
    if response.status_code == 200:
        folder_result = response.json()
    else:
        print(f"Failed to list files: {response.status_code}")
        print(response.json())

    folders = {}
    for val in folder_result['value']:
        folders[val["name"]] = val["id"]

    return folders