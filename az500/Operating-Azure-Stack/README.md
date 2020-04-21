# Operating-Azure-Stack

Exercise Files to go with the Pluralsight Course

## Introduction

Hello!  These are the exercise files to go with my Pluralsight course, Operating Azure Stack.  

## Preparing for the Course

In order to use these files, you are going to need an instance of Azure Stack, whether you choose to use the Azure Stack Development Kit or are lucky enough to have a multi-node Azure Stack.  A multi-node Azure Stack system is probably out of reach for most people, unless your company has decided to procure one.  The Azure Stack Development Kit is a single-node version of Azure Stack meant to be used for learning, testing, and development.  The hardware requirements for the ASDK are:

- 12 cores for the CPU
- 96GB of RAM
- 256GB OS drive
- 4x 256GB data drives
- Server 2012R2 compatible system

Those are the **minimum** specs.  In reality, you're going to want more memory.  The more, the better.  The ASDK is a memory hungry beast.  For this course, though, you can get by with the minimum.  If you don't happen to have that kind of hardware lying around, you can run the ASDK in Azure on an E16_v3 VM.  There will be some costs associated with doing so, but fortunately the new Standard SSD storage class makes the data disks much cheaper than they were.  In order to run the ASDK on Azure, check out this [repository](https://github.com/yagmurs/AzureStack-VM-PoC).

## Doing the exercises

The exercises assume you are starting with a fresh installation.  If you're running on a multi-node system that was prepared by someone else, then some of the steps will not be necessary.  Consult with your fellow admins before making new offers, plans, and subscriptions.  The exercises also assume you are using Azure AD for authentication and that your Azure Stack instance is connected to the internet.  If you are using ADFS and/or running in a disconnected scenario, you will need to make adjustments for certain exercises.

## Feedback

I welcome your feedback!  Please reach out to me on Twitter or log an issue on the GitHub repo.  Happy Stacking!
