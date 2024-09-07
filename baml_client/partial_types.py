###############################################################################
#
#  Welcome to Baml! To use this generated code, please run the following:
#
#  $ pip install baml
#
###############################################################################

# This file was generated by BAML: please do not edit it. Instead, edit the
# BAML files and re-generate this code.
#
# ruff: noqa: E501,F401
# flake8: noqa: E501,F401
# pylint: disable=unused-import,line-too-long
# fmt: off
import baml_py
from enum import Enum
from pydantic import BaseModel, ConfigDict
from typing import Dict, List, Optional, Union

from . import types

###############################################################################
#
#  These types are used for streaming, for when an instance of a type
#  is still being built up and any of its fields is not yet fully available.
#
###############################################################################


class CallSummaryOutput(BaseModel):
    
    
    fixedtext: Optional[str] = None

class Certification(BaseModel):
    
    
    name: Optional[str] = None
    issuing_organization: Optional[str] = None
    date_obtained: Optional[str] = None
    expiry_date: Optional[str] = None
    link: Optional[str] = None

class ContactInfo(BaseModel):
    
    
    full_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    linkedin: Optional[str] = None
    website: Optional[str] = None
    github: Optional[str] = None

class Education(BaseModel):
    
    
    institution: Optional[str] = None
    degree: Optional[str] = None
    field_of_study: Optional[str] = None
    graduation_date: Optional[str] = None
    gpa: Optional[str] = None
    honors: Optional[Union[List[Optional[str]], Optional[None]]] = None

class Evaluation(BaseModel):
    
    
    OverallScore: Optional[int] = None
    Strengths: List[Optional[str]]
    Weaknesses: List[Optional[str]]
    Explanation: List[Optional[str]]
    Recommendation: Optional[str] = None
    ApplicationStatus: Optional[types.ApplicationCategory] = None
    Questions: Optional[Union[List[Optional[str]], Optional[None]]] = None

class Experience(BaseModel):
    
    
    company: Optional[str] = None
    position: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    location: Optional[str] = None
    is_current: Optional[bool] = None
    responsibilities: Optional[Union[List[Optional[str]], Optional[None]]] = None
    achievements: Optional[Union[List[Optional[str]], Optional[None]]] = None

class FinalEvaluation(BaseModel):
    
    
    OverallScore: Optional[int] = None
    Strengths: List[Optional[str]]
    Weaknesses: List[Optional[str]]
    Explanation: List[Optional[str]]
    Recommendation: Optional[str] = None
    ApplicationStatus: Optional[types.FinalApplicationCategory] = None

class Interest(BaseModel):
    
    
    intrest: List[Optional[str]]

class Language(BaseModel):
    
    
    name: Optional[str] = None
    proficiency: Optional[types.LanguageProficiency] = None

class Project(BaseModel):
    
    
    project: Optional["Projects"] = None

class Projects(BaseModel):
    
    
    name: Optional[str] = None
    description: Optional[str] = None
    technologies: Optional[str] = None
    category: Optional[types.TypeofDevelopment] = None
    url: Optional[str] = None

class Resume(BaseModel):
    
    
    contact_info: Optional["ContactInfo"] = None
    summary: Optional[str] = None
    typeOfDevelopment: List[Optional[types.TypeofDevelopment]]
    work_experience: List["Experience"]
    education: List["Education"]
    skills: List["Skill"]
    projects: Optional[Union[List["Project"], Optional[None]]] = None
    certifications: Optional[Union[List["Certification"], Optional[None]]] = None
    languages: Optional[Union[List["Language"], Optional[None]]] = None
    interests: Optional[Union[List[Optional[str]], Optional[None]]] = None

class Skill(BaseModel):
    
    
    name: Optional[str] = None
    level: Optional[types.SkillLevel] = None
