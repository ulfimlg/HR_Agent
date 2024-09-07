import requests
import re

def get_github_repo(username:str):
    # Get the data from github
    repo_url = 'https://api.github.com/users/{}/repos'.format(username)    
    repo_data = requests.get(repo_url).json()
    return repo_data

def get_github_profile(username:str):
    # Get the data from github
    user_url = 'https://api.github.com/users/{}'.format(username)    
    user_data = requests.get(user_url).json()
    return user_data

def extract_repo_data(all_data:dict)->dict:
    # Get the required data from the dictionary
    required_repo_data = ['description','open_issues','watchers','stargazers_count','language', 'created_at', 'updated_at']
    Data = {}
    for (k, v) in all_data.items():
        if k in required_repo_data:
            Data[k] = v
    return Data

def extract_profile_data(all_data:dict)->dict:
    # Get the required data from the dictionary
    required_profile_data = ['name','company','location','email','bio','public_repos','followers','following']
    Data = {}
    for (k, v) in all_data.items():
        if k in required_profile_data:
            Data[k] = v
    return Data

def extract_github_username(url:str):
    # Regular expression to match GitHub profile URLs
    match = re.search(r'github\.com/([^/?#]+)', url)
    if match:
        return match.group(1)
    return None

def extract_github_data(url:str)-> dict:
    """
    Put together all the data required from GitHub using a url.
    """
    profile_id = extract_github_username(url)
    full_profile = get_github_profile(profile_id)
    all_repo_data = get_github_repo(profile_id)

    profile = extract_profile_data(full_profile)
    profile['id'] = profile_id
    repo_data = {}
    for repo in all_repo_data:
        repo_name = repo['name']
        repo_data[repo_name] = extract_repo_data(repo)
    profile['repositories'] = repo_data
    return profile
