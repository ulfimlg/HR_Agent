// Defining a data model.
enum TypeofDevelopment {
  FD @alias("Frontend Developer") @description(#"
    Specializes in creating the user interface and 
    experience of a website or application using HTML, CSS, and JavaScript.
    "#)
  BD @alias("Backend Developer") @description(#"
    Focuses on server-side logic, databases, and APIs to power the 
    functionalities of a web or mobile application.
    "#)
  FSD @alias("Full Stack Developer") @description(#"Skilled in both frontend and backend 
    development, capable of building a complete application from scratch.
    "#)
  MD @alias("Mobile Developer") @description(#"Develops applications specifically for mobile devices 
    using languages like Swift, Kotlin, or Java.
    "#)
  DOE @alias("DevOps Engineer") @description(#"Bridges the gap between development and operations, 
    focusing on automation, continuous integration, and deployment.
    "#)
  DE @alias("Data Engineer") @description(#"Designs and builds systems for collecting, storing, 
    and analyzing large datasets.
    "#)
  SD @alias("Security Developer") @description(#"ocuses on identifying and fixing security 
    vulnerabilities in software and systems.
    "#)
  GD @alias("Game Developer") @description(#"Creates video games, working on aspects like 
    game design, mechanics, and programming.
    "#)
  EED @alias("Embedded Systems Developer") @description(#"Works on software for embedded systems, 
    such as those found in IoT devices, appliances, and cars.
    "#)
  CD @alias("Cloud Developer") @description(#"Specializes in building and managing applications 
    that run on cloud platforms like AWS, Azure, or Google Cloud.
    "#)
  AID @alias("AI/ML Developer") @description(#"Focuses on building systems that can learn and 
    make decisions, often using neural networks and other machine learning techniques.
    "#)
  DD @alias("Database Developer") @description(#"Designs and maintains database systems 
    to ensure data integrity, security, and accessibility.
    "#)
  BLD @alias("Blockchain Developer") @description(#"Works on decentralized applications and systems 
    using blockchain technology for secure and transparent transactions.
    "#)
  ARD @alias("AR/VR Developer") @description(#"Specializes in creating augmented reality 
    - AR and virtual reality - VR experiences.
    "#)

}

enum SkillLevel{
  Beginner
  Intermediate
  Advanced
  Expert
}

enum LanguageProficiency{
  Elementary
  LimitedWorking
  ProfessionalWorking
  FullProfessional
  Native
}

enum ApplicationCategory{
  Accept
  Reject
  WorthHavingALook
}

enum FinalApplicationCategory{
  Accept
  Reject
}

class ContactInfo{
  full_name string
  email string
  phone string @description("The contact number of the candidate with the country code")
  address string?
  linkedin string? @description("The LinkedIn profile of the candidate")
  website string? 
  github string? @description("The GitHub profile of the candidate")
}

class Experience{
  company string
  position string
  start_date string @description("ISO8601 formatted date")
  end_date string? @description("ISO8601 formatted date")
  location string?
  is_current bool
  responsibilities string[] | null
  achievements string[] | null
  }

class Education{
    institution string
    degree string
    field_of_study string
    graduation_date string?
    gpa string? @description(#"
      Final GPA or grade obtained in the specified degree/educational experience.
    "#)
    honors string[] | null
}

class Skill{
    name string
    level SkillLevel @description(#"
      Expertise in the skill mention. Infer if not mentioned based on given data. 
    "#)
}

class Projects{
    name string
    description string
    technologies string
    category TypeofDevelopment
    url string?
}

class Certification{
    name string
    issuing_organization string
    date_obtained string @description("ISO8601 formatted date")
    expiry_date string?
    link string?
}

class Language{
    name string
    proficiency LanguageProficiency
}

class Interest{
  intrest string[]
}

class Project{
  project Projects?
}

class Resume{
    contact_info ContactInfo
    summary string
    typeOfDevelopment TypeofDevelopment[] @description("The type of development the candidate is interested in based on experience and description")
    work_experience Experience[]
    education Education[] @description("The education history of the candidatein the given order")
    skills Skill[] @description("The work experience of the candidate in the given order.")
    projects Project[] | null
    certifications Certification[] | null
    languages Language[] | null
    interests string[] | null @description("Intrests ot hobbies of the applicant.")
}

class CallSummaryOutput{
  fixedtext string
}
//Evaluation 
class Evaluation{
  OverallScore int
  Strengths string[]
  Weaknesses string[]
  Explanation string[]
  Recommendation string @description(#"
    How should we move ahead with this candidate and if hired how to utalize them in the role
  "#)
  ApplicationStatus ApplicationCategory
  Questions string[] | null @description(#"
    A list of 3 questions to ask the candidate to 
    come to a firm conclution weather he/she is a good fit or not a good fit.
    Only if the candidate is WorthHavingALook. Leave empty if the candidate is Accept or Reject.
  "#)
}

class FinalEvaluation{
  OverallScore int
  Strengths string[]
  Weaknesses string[]
  Explanation string[]
  Recommendation string @description(#"
    How should we move ahead with this candidate and if hired how to utalize them in the role
  "#)
  ApplicationStatus FinalApplicationCategory
}


// Creating a function to extract the resume from a string.
function ExtractResume(resume: string) -> Resume {
  client GPT4o
  prompt #"
    Extract from this content:
    {{ resume }}

    {{ ctx.output_format }}
    
    Before you output the JSON, please explain your
    reasoning step-by-step. Here is an example on how to do this:
    'If we think step by step we can see that ...
     therefore the output JSON is:
    {
      ... the json schema ...
    }'
  "#
}

function CandidateEvaluation(CANDIDATE_RESUME: string, JD: string, github: string | null) -> Evaluation {
  client GPT4o
  prompt #"
    You are an AI assistant tasked with evaluating a job candidate based on their resume, GitHub profile summary, and a job description. Your goal is to provide a comprehensive assessment of the candidate's suitability for the position.
      First, review the following information:

      <resume>
      {{CANDIDATE_RESUME}}
      </resume>

      <github_profile>
      {{github}}
      </github_profile>

      <job_description>
      {{JD}}
      </job_description>

      Now, follow these steps to evaluate the candidate:

      1. Analyze the resume and GitHub profile:
        - Identify key skills, experiences, and qualifications mentioned in the resume
        - Note any relevant projects, contributions, or activities from the GitHub profile
        - Look for any achievements, awards, or certifications that stand out

      2. Compare the candidate's qualifications to the job requirements:
        - List the main requirements and desired skills from the job description
        - Match the candidate's skills and experiences to these requirements
        - Identify any gaps or areas where the candidate exceeds expectations

      3. Provide a detailed evaluation:
        - Discuss the candidate's strengths and how they align with the job requirements
        - Address any potential weaknesses or missing qualifications
        - Consider the candidate's GitHub activity as an indicator of their coding skills and passion for technology

      4. Score the candidate and provide a final conclusion:
        - Use a scale of 1-10, where 1-4 is a not fit, 4-7 is worth having a look at and 8-10 is an good fit for the position
        - Justify your score with specific examples from the resume, GitHub profile, and job description

      Present your evaluation in the following format:

      <evaluation>
      <strengths>
      [List the candidate's main strengths and how they relate to the job requirements]
      </strengths>

      <weaknesses>
      [List any notable weaknesses or missing qualifications]
      </weaknesses>

      <github_assessment>
      [Provide an assessment of the candidate's GitHub profile and its relevance to the position]
      </github_assessment>

      <overall_evaluation>
      [Give a comprehensive evaluation of the candidate's suitability for the position]
      </overall_evaluation>

      <score_justification>
      [Explain your reasoning for the score you're about to give]
      </score_justification>

      <score>
      [Provide a score from 1-10]
      </score>
      </evaluation>

      Remember to be objective and base your evaluation solely on the information provided in the resume, GitHub profile, and job description. Do not make assumptions about the candidate beyond what is explicitly stated in these documents.
    {{ ctx.output_format }}
    Before you output the JSON, please explain your
    reasoning step-by-step. Here is an example on how to do this:
    'If we think step by step we can see that ...
     therefore the output JSON is:
    {
      ... the json schema ...
    }'
  "#
}

function FinalEvaluationOfCandidate(CANDIDATE_RESUME: string, JD: string, github: string | null, CallSummaryText: string, evaluation : string) -> FinalEvaluation {
  client GPT4o
  prompt #"
    You are an AI assistant responsible for evaluating a job candidate based on their resume, GitHub profile, job description, and a follow-up call. Your task is to deliver a thorough assessment of the candidate’s fit for the role.

Step 1: Review the provided information:

Resume: {{CANDIDATE_RESUME}}
GitHub Profile: {{github}}
Job Description: {{JD}}
Call Summary: {{CallSummaryText}}
Previous Evaluation: {{evaluation}}
Step 2: Conduct the evaluation by following these steps:

Analyze the Resume & GitHub Profile:

Identify relevant skills, experiences, and qualifications from the resume.
Highlight key projects, contributions, and activities from the GitHub profile.
Note any awards, certifications, or accomplishments.
Compare to Job Requirements:

List the key qualifications and skills from the job description.
Match the candidate’s profile against these requirements.
Highlight any gaps or areas where the candidate exceeds expectations.
Detailed Evaluation:

Outline the candidate’s strengths in relation to the job requirements.
Discuss potential weaknesses or missing qualifications.
Evaluate the candidate’s GitHub activity to assess coding skills and technical passion.
Final Score & Conclusion:

Rate the candidate on a scale from 1-10:
1-4: Not a fit
8-10: Strong fit
Justify the score with examples from the resume, GitHub profile, and job description.
Step 3: Present your evaluation in this format:

xml
Copy code
<evaluation>
  <strengths>
    [List candidate's main strengths related to the job requirements]
  </strengths>

  <weaknesses>
    [List any weaknesses or missing qualifications]
  </weaknesses>

  <github_assessment>
    [Evaluate the candidate’s GitHub profile and its relevance to the role]
  </github_assessment>

  <overall_evaluation>
    [Comprehensive assessment of the candidate’s suitability for the role]
  </overall_evaluation>

  <score_justification>
    [Justify the score based on the analysis]
  </score_justification>

  <score>
    [Provide a score from 1-10]
  </score>
</evaluation>
Be objective and focus only on the information provided. Avoid assumptions beyond the given data.
    {{ ctx.output_format }}
    Before you output the JSON, please explain your
    reasoning step-by-step. Here is an example on how to do this:
    'If we think step by step we can see that ...
     therefore the output JSON is:
    {
      ... the json schema ...
    }'
  "#
}

function FixCallSummary(callsummary: string, name : string) -> CallSummaryOutput {
  client GPT4o
  prompt #"
    Optimize text from a call with {{name}}(Fix the spelling 
    of the name in the summary if not given correctly and fix any 
    spelling 
    mistakes in the name of technologies or anything
    {{ callsummary }}

    {{ ctx.output_format }}
    
    Before you output the JSON, please explain your
    reasoning step-by-step. Here is an example on how to do this:
    'If we think step by step we can see that ...
     therefore the output JSON is:
    {
      ... the json schema ...
    }'
  "#
}
// Testing the function with a sample resume.
test vaibhav_resume {
  functions [ExtractResume]
  args {
    resume #"
    Priyansh Neema
    I am an enthusiastic Data Scientist with a strong interest in Natural Language Processing (NLP). My passion lies in continuously learning new technology. I also have experience working as a Technical Writer Engineer. Outside of work, I love traveling, writing technical blogs, playing badminton, and swimming.
    sample@mail.com +91-1234567899 fghjk.carrd.co/
    linkedin.com/in/priyansh-neema-3899a0175 github.com/Priyansh-jsk neemapriyanshrd786.medium.com
    EDUCATION
    B.Tech Computer Science
    Shri Vaishnav Vidyapeeth Vishwavidyalaya
    08/2018 - 07/2022, Indore
    WORK EXPERIENCE
    AI/ML Engineer Nomyx
    09/2023 – Present Remote
    Achievements/Tasks - Work on LLM models.
    AI/ML Engineer
    Coto: A Web3 social community app
    04/2023 - 07/2023, Remote
    Achievements/Tasks
    SKILLS
    C/C++, Data Structure, Core Java, Python, AI/Machine Learning, NLP, Image Processing/ Image Classification, LLM, OCI
    Cloud Tech: AWS, AzureOCR, Docker, Git & GitHub.
    Data Management: MySQL, MongoDB.
    Platforms: Linux, Window
    Web Technologies: HTML5, CSS.
    Developing AI/ML models and algorithms to solve real-world problems. This involves tasks such as data preprocessing, feature engineering. Frameworks and libraries used- NLTK, TensorFlow, scikit-learn.
    Work on leveraging AzureOCR and EasyOCR, which are optical character recognition (OCR) tools.
    Create and manage a MongoDB pipeline for various operations. Example- How many like, comment share on post.
    Work with Apache Airflow, which is a platform for orchestrating complex workflows and scheduling tasks.
    Work on Docker a containerization platform, to package and deploy applications and services.
    AI/ML Engineer
    Avyay Solutions is spinoff company of Krypt
    07/2022 - 04/2023, Bangalore
    Achievements/Tasks
    Developed Rules-based/NLP Process Flows. Work on ML large dataset for multi-model testing & evaluation.
    Model used- VGG16, Supervised Machine learning.
    Work on NLP, Text pre-processing, Image processing/ Image Classification. NLP pipeline- stemming and lemmatization, Bag of words, TF-IDF.
    Software Developer Intern
    HotWax Systems
    01/2022 - 06/2022, Indore
    Achievements/Tasks
    Work on Core java JSP + Servlet, MySQL. Work on Apache OFBiz framework
    LEADERSHIP & ACTIVITIES
    Technical Content Writer Intern at intervue.io
    GDG Cloud Indore: Volunteer (09/2019 - 11/2019)
    Participated in Void Hacks 2.0, an online Hackathon conducted by S.V.V.V.
    Participated in Data Science Quiz- Data Grandmasters organized by Cliff.ai
    Attend Nullcon Security Conference
    CERTIFICATES
    OpenCV for Beginners (12/2022 - 01/2023) CoRise SQL Crash Course (10/2022 - 11/2022) HackerRank: Problem Solving (03/2020 - 05/2020)
    Completed ChatGPT Prompt engineer course by DeepLearning.ai.
    PROJECTS
    MyTutor E Learning Portal ● WhatsApp Chat Analyzer
    GoLang (CRUD operation) ● Student Management
    System using JSP Servlet ● Face emotion analysis
    Image processing/Image classification ● AzureOCR
    ChatBot using LLM.
    "#
  }
}

test test_resume {
  functions [CandidateEvaluation]
  args {
    CANDIDATE_RESUME #"
      {
        "contact_info": {
          "full_name": "Priyansh Neema",
          "email": "neemapriyanshrd786@gmail.com",
          "phone": "+91-9993165137",
          "address": null,
          "linkedin": "linkedin.com/in/priyansh-neema-3899a0175",
          "website": "priyanshneema.carrd.co",
          "github": "github.com/Priyansh-jsk"
        },
        "summary": "I am an enthusiastic Data Scientist with a strong interest in Natural Language Processing (NLP). My passion lies in continuously learning new technology. I also have experience working as a Technical Writer Engineer.",
        "typeOfDevelopment": "AID",
        "work_experience": [
          {
            "company": "Nomyx",
            "position": "AI/ML Engineer",
            "start_date": "2023-09",
            "end_date": null,
            "location": "Remote",
            "is_current": true,
            "responsibilities": [
              "Work on LLM models."
              "Langchain", "CI/CD"
            ],
            "achievements": null
          },
          {
            "company": "Coto: A Web3 social community app",
            "position": "AI/ML Engineer",
            "start_date": "2023-04",
            "end_date": "2023-07",
            "location": "Remote",
            "is_current": false,
            "responsibilities": [
              "Developing AI/ML models and algorithms to solve real-world problems.",
              "Data preprocessing, feature engineering.",
              "Use of frameworks and libraries: NLTK, TensorFlow, scikit-learn.",
              "Leveraged AzureOCR and EasyOCR tools.",
              "Created and managed a MongoDB pipeline.",
              "Work with Apache Airflow for workflow orchestration.",
              "Used Docker for packaging and deploying applications and services."
            ],
            "achievements": null
          },
          {
            "company": "Avyay Solutions (spinoff company of Krypt)",
            "position": "AI/ML Engineer",
            "start_date": "2022-07",
            "end_date": "2023-04",
            "location": "Bangalore",
            "is_current": false,
            "responsibilities": [
              "Developed Rules-based/NLP Process Flows.",
              "Worked on ML large dataset for multi-model testing & evaluation.",
              "Model used: VGG16, Supervised Machine learning.",
              "Worked on NLP, Text pre-processing, Image processing/Image Classification.",
              "NLP pipeline: stemming and lemmatization, Bag of words, TF-IDF."
            ],
            "achievements": null
          },
          {
            "company": "HotWax Systems",
            "position": "Software Developer Intern",
            "start_date": "2022-01",
            "end_date": "2022-06",
            "location": "Indore",
            "is_current": false,
            "responsibilities": [
              "Worked on Core java JSP + Servlet, MySQL.",
              "Worked on Apache OFBiz framework."
            ],
            "achievements": null
          }
        ],
        "education": [
          {
            "institution": "Shri Vaishnav Vidyapeeth Vishwavidyalaya",
            "degree": "B.Tech",
            "field_of_study": "Computer Science",
            "graduation_date": "2022-07",
            "gpa": null,
            "honors": null
          }
        ],
        "skills": [
          {
            "name": "Azure",
            "level": "Advanced"
          },
          {
            "name": "Langchain",
            "level": "Advanced"
          },
          {
            "name": "Data Structure",
            "level": "Advanced"
          },
          {
            "name": "DevOps",
            "level": "Advanced"
          },
          {
            "name": "Python",
            "level": "Advanced"
          },
          {
            "name": "AI/Machine Learning",
            "level": "Advanced"
          },
          {
            "name": "NLP",
            "level": "Advanced"
          },
          {
            "name": "Image Processing/Image Classification",
            "level": "Advanced"
          },
          {
            "name": "LLM",
            "level": "Advanced"
          },
          {
            "name": "OCI",
            "level": "Intermediate"
          },
          {
            "name": "Cloud Tech: AWS, AzureOCR",
            "level": "Intermediate"
          },
          {
            "name": "Docker",
            "level": "Intermediate"
          },
          {
            "name": "Git & GitHub",
            "level": "Intermediate"
          },
          {
            "name": "MySQL",
            "level": "Advanced"
          },
          {
            "name": "MongoDB",
            "level": "Advanced"
          },
          {
            "name": "Linux",
            "level": "Intermediate"
          },
          {
            "name": "Windows",
            "level": "Intermediate"
          },
          {
            "name": "HTML5",
            "level": "Intermediate"
          },
          {
            "name": "CSS",
            "level": "Intermediate"
          }
        ],
        "projects": [
          {
            "project": {
              "name": "MyTutor E Learning Portal",
              "description": "An e-learning platform.",
              "technologies": "Not specified.",
              "category": [
                "FSD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "WhatsApp Chat Analyzer",
              "description": "A project to analyze WhatsApp chats.",
              "technologies": "Not specified.",
              "category": [
                "DE"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "GoLang (CRUD operation)",
              "description": "A CRUD operation developed using GoLang.",
              "technologies": "GoLang",
              "category": [
                "BD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "Student Management System using JSP Servlet",
              "description": "A management system for student records.",
              "technologies": "JSP, Servlet",
              "category": [
                "BD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "Face emotion analysis",
              "description": "A project for analyzing facial emotions.",
              "technologies": "Image processing/Image classification",
              "category": [
                "AID"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "AzureOCR",
              "description": "Worked with AzureOCR tools.",
              "technologies": "OCR tools",
              "category": [
                "AID"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "ChatBot using LLM",
              "description": "A chatbot built using large language models.",
              "technologies": "LLM",
              "category": [
                "AID"
              ],
              "url": null
            }
          }
        ],
        "certifications": [
          {
            "name": "OpenCV for Beginners",
            "issuing_organization": "CoRise",
            "date_obtained": "2023-01",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "SQL Crash Course",
            "issuing_organization": "CoRise",
            "date_obtained": "2022-11",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "HackerRank: Problem Solving",
            "issuing_organization": "HackerRank",
            "date_obtained": "2020-05",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "ChatGPT Prompt engineer course",
            "issuing_organization": "DeepLearning.ai",
            "date_obtained": "Not specified",
            "expiry_date": null,
            "link": null
          }
        ],
        "languages": [
          {
            "name": "English",
            "proficiency": "FullProfessional"
          }
        ],
        "interests": [
          "Traveling",
          "Writing technical blogs",
          "Playing badminton",
          "Swimming"
        ]
      }
      "#
    JD #"
      Job Description: DevOps Azure AI Engineer:   Role Overview
      We're on the hunt for an Azure Open AI DevOps Engineer to join our dynamic team. As a DevOps Engineer specialising in AI solutions, you will play a crucial role in building, testing, deploying, and maintaining cutting-edge AI applications on the Azure platform. You'll work alongside our AI Engineers, Business Analysts, Testers, Product Owners, Architects, and Scrum Masters to deliver game-changing solutions for our clients.
      Your ability to communicate effectively with these stakeholders and bridge the gap between development and operations will be crucial for the success of our AI projects.
      Key Responsibilities
      * Develop and implement AI solutions using the Azure stack, including but not limited to Azure Open AI and Azure AI Studio, implement and manage Azure-based infrastructure for AI workloads
      * Design, implement, and maintain CI/CD pipelines for AI solutions using Azure DevOps or GitHub Actions
      * Collaborate with cross-functional teams to ensure seamless integration of AI solutions, optimise deployments, performance, security, and scalability of AI solutions
      * Stay up-to-date with the latest trends and technologies in DevOps and AI and industry best practices
      * Implement best practices for DevOps and continuously improve our development and deployment processes
      * Develop and manage our Azure infrastructure using Infrastructure as Code (IaC), preferably Terraform
      * Containerise AI applications using Docker
      * Implement and manage monitoring and logging solutions using Azure Monitor and Application Insights
      * Troubleshoot and resolve issues in development, testing, and production environments
      * Interface with internal stakeholders and clients to understand infrastructure requirements
      Required Skills and Qualifications
      * Bachelor's degree in Computer Science, Engineering, or an AI or ML related field
      * 2+ years of experience in DevOps or similar roles using DevOps practices and tools
      * Strong experience with Azure cloud services, particularly in Azure Open AI and AI Studio
      * Familiarity with Infrastructure as Code concepts and tools (preferably Terraform)
      * Familiarity with Identity, RBAC and Cloud Security
      * Strong proficiency in Python programming
      * Experience with version control systems (GitHub)
      * Experience with CI/CD pipelines, preferably Azure DevOps or GitHub Actions
      * Knowledge of AI/ML concepts and frameworks (e.g., TensorFlow, PyTorch, etc.)
      * Proficiency in containerisation and orchestration (Kubernetes, AKS, etc.)
      * Extensive experience with Azure cloud platform and services, particularly:
        * Azure OpenAI Service
        * Azure Cognitive Services
        * Azure databases (e.g., CosmosDB, Azure SQL Database)
        * Azure Kubernetes Service (AKS)
        * Azure AI Studio
      * Experience working with Microsoft Bot Framework, Power Platform, Sharepoint
      * Experience with API development and management
      * Familiarity with Agile methodologies, particularly Scrum
      * Excellent problem-solving skills, analytical skills and communication skills
      Nice to Have
      * At least one of the Azure DevOps Engineer certifications (AZ-900, AZ-104, AZ-204, AZ-400)
      * At least one of the Azure AI certifications (e.g., AI-900 or AI-102)
      * Scrum Agile certification (e.g., Professional Scrum Master I) or demonstrable experience working in Scrum teams
      Preferred Qualifications
      * Experience with AWS stack, allowing for multi-cloud comparisons and migrations
      * Experience using Notion for project management and collaboration
      * Additional Azure certifications (e.g., Azure Solutions Architect Expert / AZ-305)
      * Contribution to open-source AI projects
      * Hands-on experience with Azure OpenAI Service and Azure AI Studio, including model deployment and fine-tuning
      * Familiarity with responsible AI practices and ethical considerations in AI development

      "#
    github #"
        {'name': 'Irshad',
        'company': None,
        'location': None,
        'email': None,
        'bio': None,
        'public_repos': 10,
        'followers': 0,
        'following': 1,
        'repositories': {'Action-Car-Game': {'description': "This is a game made in Unity3D. The purpose of this project is for you to enjoy the game, view it's resources and hopefully learn from it",
          'created_at': '2022-06-08T06:14:32Z',
          'updated_at': '2022-06-08T08:19:30Z',
          'stargazers_count': 0,
          'language': 'ShaderLab',
          'open_issues': 0,
          'watchers': 0},
          'Ask-Autogen-Agents': {'description': None,
          'created_at': '2023-09-23T14:38:16Z',
          'updated_at': '2024-02-18T07:58:17Z',
          'stargazers_count': 0,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 0},
          'Ask-Your-Data': {'description': None,
          'created_at': '2023-10-18T09:45:00Z',
          'updated_at': '2024-02-18T07:53:39Z',
          'stargazers_count': 0,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 0},
          'Custom-Resume-Chatbot': {'description': 'A resume chatbot using a custom LLM running locally using autogen',
          'created_at': '2024-03-06T12:54:53Z',
          'updated_at': '2024-04-02T08:19:20Z',
          'stargazers_count': 1,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 1},
          'Fashion-Clothes-Extractor': {'description': 'Extract upper and lower clothes from any image',
          'created_at': '2024-02-17T10:43:26Z',
          'updated_at': '2024-04-30T04:09:09Z',
          'stargazers_count': 1,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 1},
          'Flowise-demo': {'description': 'Drag & drop UI to build your customized LLM flow',
          'created_at': '2024-03-26T18:06:42Z',
          'updated_at': '2024-03-26T18:06:42Z',
          'stargazers_count': 0,
          'language': None,
          'open_issues': 0,
          'watchers': 0},
          'Instagram-Scraper': {'description': None,
          'created_at': '2024-02-19T10:10:53Z',
          'updated_at': '2024-02-24T13:13:24Z',
          'stargazers_count': 1,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 1},
          'Nykaa-AI-Assistant': {'description': 'A Nykaa chatbot that can suggest products, view order details, add to cart and more',
          'created_at': '2024-03-30T11:29:05Z',
          'updated_at': '2024-03-30T11:35:34Z',
          'stargazers_count': 0,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 0},
          'PandemicRunner': {'description': 'Stay out of it',
          'created_at': '2022-02-22T15:46:50Z',
          'updated_at': '2022-02-22T15:46:50Z',
          'stargazers_count': 0,
          'language': None,
          'open_issues': 0,
          'watchers': 0},
          'Predict-Fashion-Sales': {'description': 'Predict sales for fashion products using regression machine learning models',
          'created_at': '2024-02-18T08:19:30Z',
          'updated_at': '2024-02-18T15:43:27Z',
          'stargazers_count': 0,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 0}}}
    "#
  }
} 

test test_resume2 {
  functions [CandidateEvaluation]
  args {
    CANDIDATE_RESUME #"
      {
        "contact_info": {
          "full_name": "Priyansh Neema",
          "email": "neemapriyanshrd786@gmail.com",
          "phone": "+91-9993165137",
          "address": null,
          "linkedin": "linkedin.com/in/priyansh-neema-3899a0175",
          "website": "priyanshneema.carrd.co",
          "github": "github.com/Priyansh-jsk"
        },
        "summary": "I am an enthusiastic Data Scientist with a strong interest in Natural Language Processing (NLP). My passion lies in continuously learning new technology. I also have experience working as a Technical Writer Engineer.",
        "typeOfDevelopment": "AID",
        "work_experience": [
          {
            "company": "Nomyx",
            "position": "AI/ML Engineer",
            "start_date": "2023-09",
            "end_date": null,
            "location": "Remote",
            "is_current": true,
            "responsibilities": [
              "Work on LLM models."
            ],
            "achievements": null
          },
          {
            "company": "Coto: A Web3 social community app",
            "position": "AI/ML Engineer",
            "start_date": "2023-04",
            "end_date": "2023-07",
            "location": "Remote",
            "is_current": false,
            "responsibilities": [
              "Developing AI/ML models and algorithms to solve real-world problems.",
              "Data preprocessing, feature engineering.",
              "Use of frameworks and libraries: NLTK, TensorFlow, scikit-learn.",
              "Leveraged  AzureOCR and EasyOCR tools.",
              "Created and managed a MongoDB pipeline.",
              "Work with Apache Airflow for workflow orchestration.",
              "Used Docker for packaging and deploying applications and services."
            ],
            "achievements": null
          },
          {
            "company": "Avyay Solutions (spinoff company of Krypt)",
            "position": "AI/ML Engineer",
            "start_date": "2022-07",
            "end_date": "2023-04",
            "location": "Bangalore",
            "is_current": false,
            "responsibilities": [
              "Developed Rules-based/NLP Process Flows.",
              "Worked on ML large dataset for multi-model testing & evaluation.",
              "Model used: VGG16, Supervised Machine learning.",
              "Worked on NLP, Text pre-processing, Image processing/Image Classification.",
              "NLP pipeline: stemming and lemmatization, Bag of words, TF-IDF."
            ],
            "achievements": null
          },
          {
            "company": "HotWax Systems",
            "position": "Software Developer Intern",
            "start_date": "2022-01",
            "end_date": "2022-06",
            "location": "Indore",
            "is_current": false,
            "responsibilities": [
              "Worked on Core java JSP + Servlet, MySQL.",
              "Worked on Apache OFBiz framework."
            ],
            "achievements": null
          }
        ],
        "education": [
          {
            "institution": "Shri Vaishnav Vidyapeeth Vishwavidyalaya",
            "degree": "B.Tech",
            "field_of_study": "Computer Science",
            "graduation_date": "2022-07",
            "gpa": null,
            "honors": null
          }
        ],
        "skills": [
          {
            "name": "C/C++",
            "level": "Advanced"
          },
          {
            "name": "Data Structure",
            "level": "Advanced"
          },
          {
            "name": "Core Java",
            "level": "Advanced"
          },
          {
            "name": "Python",
            "level": "Advanced"
          },
          {
            "name": "AI/Machine Learning",
            "level": "Advanced"
          },
          {
            "name": "NLP",
            "level": "Advanced"
          },
          {
            "name": "Image Processing/Image Classification",
            "level": "Advanced"
          },
          {
            "name": "LLM",
            "level": "Advanced"
          },
          {
            "name": "OCI",
            "level": "Intermediate"
          },
          {
            "name": "Cloud Tech: AWS, AzureOCR",
            "level": "Intermediate"
          },
          {
            "name": "Docker",
            "level": "Intermediate"
          },
          {
            "name": "Git & GitHub",
            "level": "Intermediate"
          },
          {
            "name": "MySQL",
            "level": "Advanced"
          },
          {
            "name": "MongoDB",
            "level": "Advanced"
          },
          {
            "name": "Linux",
            "level": "Intermediate"
          },
          {
            "name": "Windows",
            "level": "Intermediate"
          },
          {
            "name": "HTML5",
            "level": "Intermediate"
          },
          {
            "name": "CSS",
            "level": "Intermediate"
          }
        ],
        "projects": [
          {
            "project": {
              "name": "MyTutor E Learning Portal",
              "description": "An e-learning platform.",
              "technologies": "Not specified.",
              "category": [
                "FSD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "WhatsApp Chat Analyzer",
              "description": "A project to analyze WhatsApp chats.",
              "technologies": "Not specified.",
              "category": [
                "DE"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "GoLang (CRUD operation)",
              "description": "A CRUD operation developed using GoLang.",
              "technologies": "GoLang",
              "category": [
                "BD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "Student Management System using JSP Servlet",
              "description": "A management system for student records.",
              "technologies": "JSP, Servlet",
              "category": [
                "BD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "Face emotion analysis",
              "description": "A project for analyzing facial emotions.",
              "technologies": "Image processing/Image classification",
              "category": [
                "AID"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "AzureOCR",
              "description": "Worked with AzureOCR tools.",
              "technologies": "OCR tools",
              "category": [
                "AID"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "ChatBot using LLM",
              "description": "A chatbot built using large language models.",
              "technologies": "LLM",
              "category": [
                "AID"
              ],
              "url": null
            }
          }
        ],
        "certifications": [
          {
            "name": "OpenCV for Beginners",
            "issuing_organization": "CoRise",
            "date_obtained": "2023-01",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "SQL Crash Course",
            "issuing_organization": "CoRise",
            "date_obtained": "2022-11",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "HackerRank: Problem Solving",
            "issuing_organization": "HackerRank",
            "date_obtained": "2020-05",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "ChatGPT Prompt engineer course",
            "issuing_organization": "DeepLearning.ai",
            "date_obtained": "Not specified",
            "expiry_date": null,
            "link": null
          }
        ],
        "languages": [
          {
            "name": "English",
            "proficiency": "FullProfessional"
          }
        ],
        "interests": [
          "Traveling",
          "Writing technical blogs",
          "Playing badminton",
          "Swimming"
        ]
      }
      "#
    JD #"
      Job Description: DevOps Azure AI Engineer:   Role Overview
      We're on the hunt for an Azure Open AI DevOps Engineer to join our dynamic team. As a DevOps Engineer specialising in AI solutions, you will play a crucial role in building, testing, deploying, and maintaining cutting-edge AI applications on the Azure platform. You'll work alongside our AI Engineers, Business Analysts, Testers, Product Owners, Architects, and Scrum Masters to deliver game-changing solutions for our clients.
      Your ability to communicate effectively with these stakeholders and bridge the gap between development and operations will be crucial for the success of our AI projects.
      Key Responsibilities
      * Develop and implement AI solutions using the Azure stack, including but not limited to Azure Open AI and Azure AI Studio, implement and manage Azure-based infrastructure for AI workloads
      * Design, implement, and maintain CI/CD pipelines for AI solutions using Azure DevOps or GitHub Actions
      * Collaborate with cross-functional teams to ensure seamless integration of AI solutions, optimise deployments, performance, security, and scalability of AI solutions
      * Stay up-to-date with the latest trends and technologies in DevOps and AI and industry best practices
      * Implement best practices for DevOps and continuously improve our development and deployment processes
      * Develop and manage our Azure infrastructure using Infrastructure as Code (IaC), preferably Terraform
      * Containerise AI applications using Docker
      * Implement and manage monitoring and logging solutions using Azure Monitor and Application Insights
      * Troubleshoot and resolve issues in development, testing, and production environments
      * Interface with internal stakeholders and clients to understand infrastructure requirements
      Required Skills and Qualifications
      * Bachelor's degree in Computer Science, Engineering, or an AI or ML related field
      * 2+ years of experience in DevOps or similar roles using DevOps practices and tools
      * Strong experience with Azure cloud services, particularly in Azure Open AI and AI Studio
      * Familiarity with Infrastructure as Code concepts and tools (preferably Terraform)
      * Familiarity with Identity, RBAC and Cloud Security
      * Strong proficiency in Python programming
      * Experience with version control systems (GitHub)
      * Experience with CI/CD pipelines, preferably Azure DevOps or GitHub Actions
      * Knowledge of AI/ML concepts and frameworks (e.g., TensorFlow, PyTorch, etc.)
      * Proficiency in containerisation and orchestration (Kubernetes, AKS, etc.)
      * Extensive experience with Azure cloud platform and services, particularly:
        * Azure OpenAI Service
        * Azure Cognitive Services
        * Azure databases (e.g., CosmosDB, Azure SQL Database)
        * Azure Kubernetes Service (AKS)
        * Azure AI Studio
      * Experience working with Microsoft Bot Framework, Power Platform, Sharepoint
      * Experience with API development and management
      * Familiarity with Agile methodologies, particularly Scrum
      * Excellent problem-solving skills, analytical skills and communication skills
      Nice to Have
      * At least one of the Azure DevOps Engineer certifications (AZ-900, AZ-104, AZ-204, AZ-400)
      * At least one of the Azure AI certifications (e.g., AI-900 or AI-102)
      * Scrum Agile certification (e.g., Professional Scrum Master I) or demonstrable experience working in Scrum teams
      Preferred Qualifications
      * Experience with AWS stack, allowing for multi-cloud comparisons and migrations
      * Experience using Notion for project management and collaboration
      * Additional Azure certifications (e.g., Azure Solutions Architect Expert / AZ-305)
      * Contribution to open-source AI projects
      * Hands-on experience with Azure OpenAI Service and Azure AI Studio, including model deployment and fine-tuning
      * Familiarity with responsible AI practices and ethical considerations in AI development

      "#
    github #"
        {'name': 'Irshad',
        'company': None,
        'location': None,
        'email': None,
        'bio': None,
        'public_repos': 10,
        'followers': 0,
        'following': 1,
        'repositories': {'Action-Car-Game': {'description': "This is a game made in Unity3D. The purpose of this project is for you to enjoy the game, view it's resources and hopefully learn from it",
          'created_at': '2022-06-08T06:14:32Z',
          'updated_at': '2022-06-08T08:19:30Z',
          'stargazers_count': 0,
          'language': 'ShaderLab',
          'open_issues': 0,
          'watchers': 0},
          'Ask-Autogen-Agents': {'description': None,
          'created_at': '2023-09-23T14:38:16Z',
          'updated_at': '2024-02-18T07:58:17Z',
          'stargazers_count': 0,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 0},
          'Ask-Your-Data': {'description': None,
          'created_at': '2023-10-18T09:45:00Z',
          'updated_at': '2024-02-18T07:53:39Z',
          'stargazers_count': 0,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 0},
          'Custom-Resume-Chatbot': {'description': 'A resume chatbot using a custom LLM running locally using autogen',
          'created_at': '2024-03-06T12:54:53Z',
          'updated_at': '2024-04-02T08:19:20Z',
          'stargazers_count': 1,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 1},
          'Fashion-Clothes-Extractor': {'description': 'Extract upper and lower clothes from any image',
          'created_at': '2024-02-17T10:43:26Z',
          'updated_at': '2024-04-30T04:09:09Z',
          'stargazers_count': 1,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 1},
          'Flowise-demo': {'description': 'Drag & drop UI to build your customized LLM flow',
          'created_at': '2024-03-26T18:06:42Z',
          'updated_at': '2024-03-26T18:06:42Z',
          'stargazers_count': 0,
          'language': None,
          'open_issues': 0,
          'watchers': 0},
          'Instagram-Scraper': {'description': None,
          'created_at': '2024-02-19T10:10:53Z',
          'updated_at': '2024-02-24T13:13:24Z',
          'stargazers_count': 1,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 1},
          'Nykaa-AI-Assistant': {'description': 'A Nykaa chatbot that can suggest products, view order details, add to cart and more',
          'created_at': '2024-03-30T11:29:05Z',
          'updated_at': '2024-03-30T11:35:34Z',
          'stargazers_count': 0,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 0},
          'PandemicRunner': {'description': 'Stay out of it',
          'created_at': '2022-02-22T15:46:50Z',
          'updated_at': '2022-02-22T15:46:50Z',
          'stargazers_count': 0,
          'language': None,
          'open_issues': 0,
          'watchers': 0},
          'Predict-Fashion-Sales': {'description': 'Predict sales for fashion products using regression machine learning models',
          'created_at': '2024-02-18T08:19:30Z',
          'updated_at': '2024-02-18T15:43:27Z',
          'stargazers_count': 0,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 0}}}
    "#
  }
} 

test test_final_analizer {
  functions [FinalEvaluationOfCandidate]
  args {
    CANDIDATE_RESUME #"
      {
        "contact_info": {
          "full_name": "Priyansh Neema",
          "email": "neemapriyanshrd786@gmail.com",
          "phone": "+91-9993165137",
          "address": null,
          "linkedin": "linkedin.com/in/priyansh-neema-3899a0175",
          "website": "priyanshneema.carrd.co",
          "github": "github.com/Priyansh-jsk"
        },
        "summary": "I am an enthusiastic Data Scientist with a strong interest in Natural Language Processing (NLP). My passion lies in continuously learning new technology. I also have experience working as a Technical Writer Engineer.",
        "typeOfDevelopment": "AID",
        "work_experience": [
          {
            "company": "Nomyx",
            "position": "AI/ML Engineer",
            "start_date": "2023-09",
            "end_date": null,
            "location": "Remote",
            "is_current": true,
            "responsibilities": [
              "Work on LLM models."
            ],
            "achievements": null
          },
          {
            "company": "Coto: A Web3 social community app",
            "position": "AI/ML Engineer",
            "start_date": "2023-04",
            "end_date": "2023-07",
            "location": "Remote",
            "is_current": false,
            "responsibilities": [
              "Developing AI/ML models and algorithms to solve real-world problems.",
              "Data preprocessing, feature engineering.",
              "Use of frameworks and libraries: NLTK, TensorFlow, scikit-learn.",
              "Leveraged  AzureOCR and EasyOCR tools.",
              "Created and managed a MongoDB pipeline.",
              "Work with Apache Airflow for workflow orchestration.",
              "Used Docker for packaging and deploying applications and services."
            ],
            "achievements": null
          },
          {
            "company": "Avyay Solutions (spinoff company of Krypt)",
            "position": "AI/ML Engineer",
            "start_date": "2022-07",
            "end_date": "2023-04",
            "location": "Bangalore",
            "is_current": false,
            "responsibilities": [
              "Developed Rules-based/NLP Process Flows.",
              "Worked on ML large dataset for multi-model testing & evaluation.",
              "Model used: VGG16, Supervised Machine learning.",
              "Worked on NLP, Text pre-processing, Image processing/Image Classification.",
              "NLP pipeline: stemming and lemmatization, Bag of words, TF-IDF."
            ],
            "achievements": null
          },
          {
            "company": "HotWax Systems",
            "position": "Software Developer Intern",
            "start_date": "2022-01",
            "end_date": "2022-06",
            "location": "Indore",
            "is_current": false,
            "responsibilities": [
              "Worked on Core java JSP + Servlet, MySQL.",
              "Worked on Apache OFBiz framework."
            ],
            "achievements": null
          }
        ],
        "education": [
          {
            "institution": "Shri Vaishnav Vidyapeeth Vishwavidyalaya",
            "degree": "B.Tech",
            "field_of_study": "Computer Science",
            "graduation_date": "2022-07",
            "gpa": null,
            "honors": null
          }
        ],
        "skills": [
          {
            "name": "C/C++",
            "level": "Advanced"
          },
          {
            "name": "Data Structure",
            "level": "Advanced"
          },
          {
            "name": "Core Java",
            "level": "Advanced"
          },
          {
            "name": "Python",
            "level": "Advanced"
          },
          {
            "name": "AI/Machine Learning",
            "level": "Advanced"
          },
          {
            "name": "NLP",
            "level": "Advanced"
          },
          {
            "name": "Image Processing/Image Classification",
            "level": "Advanced"
          },
          {
            "name": "LLM",
            "level": "Advanced"
          },
          {
            "name": "OCI",
            "level": "Intermediate"
          },
          {
            "name": "Cloud Tech: AWS, AzureOCR",
            "level": "Intermediate"
          },
          {
            "name": "Docker",
            "level": "Intermediate"
          },
          {
            "name": "Git & GitHub",
            "level": "Intermediate"
          },
          {
            "name": "MySQL",
            "level": "Advanced"
          },
          {
            "name": "MongoDB",
            "level": "Advanced"
          },
          {
            "name": "Linux",
            "level": "Intermediate"
          },
          {
            "name": "Windows",
            "level": "Intermediate"
          },
          {
            "name": "HTML5",
            "level": "Intermediate"
          },
          {
            "name": "CSS",
            "level": "Intermediate"
          }
        ],
        "projects": [
          {
            "project": {
              "name": "MyTutor E Learning Portal",
              "description": "An e-learning platform.",
              "technologies": "Not specified.",
              "category": [
                "FSD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "WhatsApp Chat Analyzer",
              "description": "A project to analyze WhatsApp chats.",
              "technologies": "Not specified.",
              "category": [
                "DE"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "GoLang (CRUD operation)",
              "description": "A CRUD operation developed using GoLang.",
              "technologies": "GoLang",
              "category": [
                "BD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "Student Management System using JSP Servlet",
              "description": "A management system for student records.",
              "technologies": "JSP, Servlet",
              "category": [
                "BD"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "Face emotion analysis",
              "description": "A project for analyzing facial emotions.",
              "technologies": "Image processing/Image classification",
              "category": [
                "AID"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "AzureOCR",
              "description": "Worked with AzureOCR tools.",
              "technologies": "OCR tools",
              "category": [
                "AID"
              ],
              "url": null
            }
          },
          {
            "project": {
              "name": "ChatBot using LLM",
              "description": "A chatbot built using large language models.",
              "technologies": "LLM",
              "category": [
                "AID"
              ],
              "url": null
            }
          }
        ],
        "certifications": [
          {
            "name": "OpenCV for Beginners",
            "issuing_organization": "CoRise",
            "date_obtained": "2023-01",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "SQL Crash Course",
            "issuing_organization": "CoRise",
            "date_obtained": "2022-11",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "HackerRank: Problem Solving",
            "issuing_organization": "HackerRank",
            "date_obtained": "2020-05",
            "expiry_date": null,
            "link": null
          },
          {
            "name": "ChatGPT Prompt engineer course",
            "issuing_organization": "DeepLearning.ai",
            "date_obtained": "Not specified",
            "expiry_date": null,
            "link": null
          }
        ],
        "languages": [
          {
            "name": "English",
            "proficiency": "FullProfessional"
          }
        ],
        "interests": [
          "Traveling",
          "Writing technical blogs",
          "Playing badminton",
          "Swimming"
        ]
      }
      "#
    JD #"
      Job Description: DevOps Azure AI Engineer:   Role Overview
      We're on the hunt for an Azure Open AI DevOps Engineer to join our dynamic team. As a DevOps Engineer specialising in AI solutions, you will play a crucial role in building, testing, deploying, and maintaining cutting-edge AI applications on the Azure platform. You'll work alongside our AI Engineers, Business Analysts, Testers, Product Owners, Architects, and Scrum Masters to deliver game-changing solutions for our clients.
      Your ability to communicate effectively with these stakeholders and bridge the gap between development and operations will be crucial for the success of our AI projects.
      Key Responsibilities
      * Develop and implement AI solutions using the Azure stack, including but not limited to Azure Open AI and Azure AI Studio, implement and manage Azure-based infrastructure for AI workloads
      * Design, implement, and maintain CI/CD pipelines for AI solutions using Azure DevOps or GitHub Actions
      * Collaborate with cross-functional teams to ensure seamless integration of AI solutions, optimise deployments, performance, security, and scalability of AI solutions
      * Stay up-to-date with the latest trends and technologies in DevOps and AI and industry best practices
      * Implement best practices for DevOps and continuously improve our development and deployment processes
      * Develop and manage our Azure infrastructure using Infrastructure as Code (IaC), preferably Terraform
      * Containerise AI applications using Docker
      * Implement and manage monitoring and logging solutions using Azure Monitor and Application Insights
      * Troubleshoot and resolve issues in development, testing, and production environments
      * Interface with internal stakeholders and clients to understand infrastructure requirements
      Required Skills and Qualifications
      * Bachelor's degree in Computer Science, Engineering, or an AI or ML related field
      * 2+ years of experience in DevOps or similar roles using DevOps practices and tools
      * Strong experience with Azure cloud services, particularly in Azure Open AI and AI Studio
      * Familiarity with Infrastructure as Code concepts and tools (preferably Terraform)
      * Familiarity with Identity, RBAC and Cloud Security
      * Strong proficiency in Python programming
      * Experience with version control systems (GitHub)
      * Experience with CI/CD pipelines, preferably Azure DevOps or GitHub Actions
      * Knowledge of AI/ML concepts and frameworks (e.g., TensorFlow, PyTorch, etc.)
      * Proficiency in containerisation and orchestration (Kubernetes, AKS, etc.)
      * Extensive experience with Azure cloud platform and services, particularly:
        * Azure OpenAI Service
        * Azure Cognitive Services
        * Azure databases (e.g., CosmosDB, Azure SQL Database)
        * Azure Kubernetes Service (AKS)
        * Azure AI Studio
      * Experience working with Microsoft Bot Framework, Power Platform, Sharepoint
      * Experience with API development and management
      * Familiarity with Agile methodologies, particularly Scrum
      * Excellent problem-solving skills, analytical skills and communication skills
      Nice to Have
      * At least one of the Azure DevOps Engineer certifications (AZ-900, AZ-104, AZ-204, AZ-400)
      * At least one of the Azure AI certifications (e.g., AI-900 or AI-102)
      * Scrum Agile certification (e.g., Professional Scrum Master I) or demonstrable experience working in Scrum teams
      Preferred Qualifications
      * Experience with AWS stack, allowing for multi-cloud comparisons and migrations
      * Experience using Notion for project management and collaboration
      * Additional Azure certifications (e.g., Azure Solutions Architect Expert / AZ-305)
      * Contribution to open-source AI projects
      * Hands-on experience with Azure OpenAI Service and Azure AI Studio, including model deployment and fine-tuning
      * Familiarity with responsible AI practices and ethical considerations in AI development

      "#
    github #"
        {'name': 'Irshad',
        'company': None,
        'location': None,
        'email': None,
        'bio': None,
        'public_repos': 10,
        'followers': 0,
        'following': 1,
        'repositories': {'Action-Car-Game': {'description': "This is a game made in Unity3D. The purpose of this project is for you to enjoy the game, view it's resources and hopefully learn from it",
          'created_at': '2022-06-08T06:14:32Z',
          'updated_at': '2022-06-08T08:19:30Z',
          'stargazers_count': 0,
          'language': 'ShaderLab',
          'open_issues': 0,
          'watchers': 0},
          'Ask-Autogen-Agents': {'description': None,
          'created_at': '2023-09-23T14:38:16Z',
          'updated_at': '2024-02-18T07:58:17Z',
          'stargazers_count': 0,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 0},
          'Ask-Your-Data': {'description': None,
          'created_at': '2023-10-18T09:45:00Z',
          'updated_at': '2024-02-18T07:53:39Z',
          'stargazers_count': 0,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 0},
          'Custom-Resume-Chatbot': {'description': 'A resume chatbot using a custom LLM running locally using autogen',
          'created_at': '2024-03-06T12:54:53Z',
          'updated_at': '2024-04-02T08:19:20Z',
          'stargazers_count': 1,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 1},
          'Fashion-Clothes-Extractor': {'description': 'Extract upper and lower clothes from any image',
          'created_at': '2024-02-17T10:43:26Z',
          'updated_at': '2024-04-30T04:09:09Z',
          'stargazers_count': 1,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 1},
          'Flowise-demo': {'description': 'Drag & drop UI to build your customized LLM flow',
          'created_at': '2024-03-26T18:06:42Z',
          'updated_at': '2024-03-26T18:06:42Z',
          'stargazers_count': 0,
          'language': None,
          'open_issues': 0,
          'watchers': 0},
          'Instagram-Scraper': {'description': None,
          'created_at': '2024-02-19T10:10:53Z',
          'updated_at': '2024-02-24T13:13:24Z',
          'stargazers_count': 1,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 1},
          'Nykaa-AI-Assistant': {'description': 'A Nykaa chatbot that can suggest products, view order details, add to cart and more',
          'created_at': '2024-03-30T11:29:05Z',
          'updated_at': '2024-03-30T11:35:34Z',
          'stargazers_count': 0,
          'language': 'Python',
          'open_issues': 0,
          'watchers': 0},
          'PandemicRunner': {'description': 'Stay out of it',
          'created_at': '2022-02-22T15:46:50Z',
          'updated_at': '2022-02-22T15:46:50Z',
          'stargazers_count': 0,
          'language': None,
          'open_issues': 0,
          'watchers': 0},
          'Predict-Fashion-Sales': {'description': 'Predict sales for fashion products using regression machine learning models',
          'created_at': '2024-02-18T08:19:30Z',
          'updated_at': '2024-02-18T15:43:27Z',
          'stargazers_count': 0,
          'language': 'Jupyter Notebook',
          'open_issues': 0,
          'watchers': 0}}}
    "#
    CallSummaryText #"The call was a screening interview with Nazim Girach, 
    a job candidate, to discuss his experience and qualifications for a position 
    at the company. Nazim confirmed his interest in the role and shared his 
    background in working with Azure, specifically with Azure OpenAI for 
    analytics development. However, he clarified that his experience is 
    limited to development and not deployment of AI/ML models. Additionally, 
    Nazim mentioned his proficiency in using GitHub Actions for CI/CD pipelines, 
    but not Azure DevOps. The conversation was brief and to the point, with 
    the assistant concluding the call by thanking Nazim for his time and 
    promising to follow up soon regarding next steps.
    "#
    evaluation #"{
  "OverallScore": 7,
  "Strengths": [
    "Extensive experience with AI/ML frameworks and technologies",
    "Strong hands-on experience with Azure cloud services",
    "Proficiency in Python and Docker",
    "Practical experience in data processing and deploying AI applications",
    "Solid background in DevOps and CI/CD pipelines"
  ],
  "Weaknesses": [
    "No direct mention of experience with Infrastructure as Code (Terraform)",
    "Limited specific mention of Azure AI Studio experience",
    "Not familiar with Microsoft's Bot Framework, Power Platform, or SharePoint"
  ],
  "Explanation": [
    "The candidate has advanced skills in key areas required for the position, including AI/ML, NLP, Azure services, and DevOps practices.",
    "Their GitHub profile provides evidence of practical and recent engagement in projects that relate directly to the job description.",
    "While there are minor gaps in specific experiences with some Azure services and tools like Terraform, the candidate’s strengths in other areas make them very suitable for consideration."
  ],
  "Recommendation": "The candidate has demonstrated strong capabilities and recent practical experience aligning with the job requirements. It is recommended to consider the candidate for further evaluation to address minor skills gaps and validate their fit for the role.",
  "ApplicationStatus": "WorthHavingALook",
  "Questions": [
    "Can you elaborate on your experience with Infrastructure as Code, particularly Terraform?",
    "Do you have any hands-on experience with Azure AI Studio, and if so, could you describe a project where you utilized it?",
    "How do you approach security and scalability when deploying AI applications on the Azure platform?"
  ]
  }
  "#
  }
} 

test fixSummary {
  functions [FixCallSummary]
  args {
    name #"Nazim Girach"#
    callsummary #"
      The call was a screening interview with Nasib, a job candidate, to discuss his experience and qualifications for a position at the company. Nasib confirmed his interest in the role and shared his background in working with Azure, specifically with Azure OpenAir for analytics development. However, he clarified that his experience is limited to development and not deployment of AI/ML models. Additionally, Nasib mentioned his proficiency in using GitHub Actions for CI/CD pipelines, but not Azure DevOps. The conversation was brief and to the point, with the assistant concluding the call by thanking Nasib for his time and promising to be in touch soon regarding next steps.
    "#
    
  }
} 