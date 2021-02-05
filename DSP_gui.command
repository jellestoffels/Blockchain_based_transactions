#!/usr/bin/env python

import tkinter as tk
from tkinter import font as tkfont
import datetime
import pandas as pd
import numpy as np
import os, sys
import json
import time
import hashlib

class App(tk.Tk):

    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        self.title_font = tkfont.Font(family='Helvetica', size=24, weight="bold")
        self.subtitle_font = tkfont.Font(family='Helvetica', size=18) 
        self.body_font = tkfont.Font(family='Helvetica', size=14)
        self.small_font = tkfont.Font(family='Helvetica', size=12)
        self.error_font = tkfont.Font(family='Helvetica', size=18, slant='italic')
        
        TransactionPage.state = 'idle'

        # the container is where we'll stack a bunch of frames
        # on top of each other, then the one we want visible
        # will be raised above the others
        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}
        for F,geometry in zip(
            (HomePage, BlockchainPage, TransactionPage, SearchPage, LoginPage),
            ('600x500','600x500', '600x650', '600x800', '400x400')):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            # store the frame and the geometry for this frame
            self.frames[page_name] = (frame, geometry)

            # put all of the pages in the same location;
            # the one on the top of the stacking order
            # will be the one that is visible.
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame("LoginPage")

    def show_frame(self, page_name):
        '''Show a frame for the given page name'''
        frame, geometry = self.frames[page_name]
        # change geometry of the window
        self.update_idletasks()
        self.geometry(geometry)
        frame.tkraise()

        # clear underside
#
#        whitespace = tk.Frame(width=600, height=200, bg="white")
#        whitespace.pack()
#        whitespace.place(y=450)


    def login(self, e1, e2):
        
        global username
        global user_password
        
        username = e1
        user_password = self.encrypt(e2)

        self.username = e1
        self.user_password = self.encrypt(e2)

        self.show_frame("HomePage")

    def encrypt(self, input):
        return hashlib.sha256(input.encode()).hexdigest()
        
#############
### Pages ###
#############

class LoginPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller

        label = tk.Label(self, text="Data Systems Project", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)
        label = tk.Label(self, text="Login", font=controller.subtitle_font)
        label.pack(side="top", fill="x", pady=10)

        label = tk.Label(self, text="Username", font=controller.body_font)
        label.pack(side="top", fill="x", pady=10)
        e1 = tk.Entry(self, width=30)
        e1.pack(side="top")
        label = tk.Label(self, text="Password", font=controller.body_font)
        label.pack(side="top", fill="x", pady=10)
        e2 = tk.Entry(self, width=30, show="*")
        e2.pack(side="top")

        button1 = tk.Button(self, text="Login",
            command=lambda: controller.login(e1.get(),e2.get()),
            height=5, width=30, bg='#6666FF')
        button1.pack(side='top', pady=10)

class HomePage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        BackEnd.whitespace(20)
        label = tk.Label(self, text="Data Systems Project", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)
        label = tk.Label(self, text="Blockchain based transactions", font=controller.subtitle_font)
        label.pack(side="top", fill="x", pady=10)

        button1 = tk.Button(self, text="Create Blockchain",
                            command=lambda: controller.show_frame("BlockchainPage"),
                            height=5, width=30, bg='#6666FF')
        button2 = tk.Button(self, text="Create Transaction",
                            command=lambda: controller.show_frame("TransactionPage"),
                            height=5, width=30, bg='#6666FF')
        button3 = tk.Button(self, text="Search Transaction",
                    command=lambda: controller.show_frame("SearchPage"),
                    height=5, width=30, bg='#6666FF')

        button1.pack(pady=5)
        button2.pack(pady=5)
        button3.pack(pady=5)

class BlockchainPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        
        label = tk.Label(self, text="Data Systems Project", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)
        label = tk.Label(self, text="Create Blockchain", font=controller.subtitle_font)
        label.pack(side="top", fill="x", pady=10)  

        label = tk.Label(self, text="Blockchain name", font=controller.body_font)
        label.pack(side="top", fill="x", pady=10)
        e3 = tk.Entry(self, width=30)
        e3.pack(side="top")

        button3 = tk.Button(self, text="Create",
                            command=lambda: self.Create_blockchain(e3.get()),
                            height=5, width=30, bg='#6666FF')
        button3.pack(pady=5)

        button4 = tk.Button(self, text="Back",
                   command=lambda: controller.show_frame("HomePage"),
                   height=5, width=30, bg='#6666FF')
        button4.pack(pady=5)
        
    def Create_blockchain(self, name):
        
        # Create dataframe
        todays_date = datetime.datetime.now().date()
        index = pd.date_range(todays_date-datetime.timedelta(10), periods=10, freq='D')

        Columns = ['hash','user','date','Transaction_name', 'Transaction_type', 'Password', 'filepath','Blockchain_name']

        df = pd.DataFrame(columns=Columns)
        
        # Add current user as a user on the blockchain
        date = round(time.time() * 1000)
        user = username
        Hash = App.encrypt(self, str(date)+user)
        data = [Hash, user, date, user, 'account', user_password, '', name]
        df = df.append(dict(zip(df.columns,data)), ignore_index=True)
        output = os.path.dirname(sys.argv[0]) + "/Blockchain/" + name + r'.json'
        df.to_json(output, orient='columns')

        label = tk.Label(self, text=("Blockchain saved at: " + output))
        label.pack(side="top", fill="x", pady=10)
        label.place(x=10, y=450)


class TransactionPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        
        if self.state == 'Blockchain_error':
            label = tk.Label(self, text="Blockchain not found!", font=controller.error_font)
            label.pack()
            
        label = tk.Label(self, text="Data Systems Project", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)
        label = tk.Label(self, text="Create Transaction", font=controller.subtitle_font)
        label.pack(side="top", fill="x", pady=10)

        label = tk.Label(self, text="Transaction name", font=controller.body_font)
        label.pack()
        e5 = tk.Entry(self, width=30)
        e5.pack(side="top")
        
        label = tk.Label(self, text="Transaction type", font=controller.body_font)
        label.pack()
        label = tk.Label(self, text="(Choose between: Signature, File, Request, account)", font=controller.small_font)
        label.pack()

        e6 = tk.Entry(self, width=30)
        e6.pack(side="top")
        label = tk.Label(self, text="Password", font=controller.body_font)
        label.pack()
        label = tk.Label(self, text="(Only if creating an account)", font=controller.small_font)
        label.pack()

        e7 = tk.Entry(self, width=30)
        e7.pack(side="top")
        
        label = tk.Label(self, text="Blockchain name", font=controller.body_font)
        label.pack()
        e8 = tk.Entry(self, width=30)
        e8.pack(side="top")

        button3 = tk.Button(self, text="Create",
                            command=lambda: self.Create_transaction(
                            e5.get(),e6.get(), e7.get(),e8.get()),
                            height=5, width=30, bg='#6666FF')
        button3.pack(pady=5)

        button4 = tk.Button(self, text="Back",
                   command=lambda: controller.show_frame("HomePage"),
                   height=5, width=30, bg='#6666FF')
        button4.pack(pady=5)
        
    def Create_transaction(self, Transaction_name, Transaction_type, Password, Blockchain_name):

        # 1. load blockchain
        file = os.path.dirname(sys.argv[0]) + "/Blockchain/" + Blockchain_name + r'.json'
        
        with open(file) as input:
            input = json.load(input)
            df = pd.DataFrame.from_dict(input, orient='columns')
            
        # 2. generate data for new transaction
        Columns = ['hash','user','date','Transaction_name', 'Transaction_type', 'Password', 'filepath','Blockchain_name']
        
        todays_date = datetime.datetime.now().date()
        date = round(time.time() * 1000)
        user = username
        Hash = App.encrypt(self, str(date)+user)
        Password = App.encrypt(self, Password)
        users = df.loc[df['Transaction_name'] == user]['Transaction_name'].values
        correct_passwords = df.loc[df['Transaction_name'] == user]['Password'].values
        Transaction_type = Transaction_type.lower()
        
        if Transaction_type == 'file':
            filepath = os.path.dirname(sys.argv[0]) + "/Linked_data/" + Transaction_name
        else:
            filepath = ''
        
        data = [Hash, user, date, Transaction_name, Transaction_type, Password, filepath, Blockchain_name]
        
        # 2. Check if user is on the blockchain:
        if user in users:
            if user_password in correct_passwords:
                # 3. Update blockchain
                df = df.append(dict(zip(df.columns,data)), ignore_index=True)
                df.to_json(os.path.dirname(sys.argv[0]) + "/Blockchain/" + Blockchain_name + r'.json',orient='columns')
                
                label = tk.Label(self, text=("Transaction saved: " + Transaction_name))
                label.pack(side="top", fill="x", pady=10)
                
            else:
                label = tk.Label(self, text=("password incorrect"))
                label.pack(side="top", fill="x", pady=10)
        else:
            label = tk.Label(self, text=('user not found: '+ user))
            label.pack(side="top", fill="x", pady=10)

class SearchPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        
        label = tk.Label(self, text="Data Systems Project", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)
        label = tk.Label(self, text="Search Transactions", font=controller.subtitle_font)
        label.pack(side="top", fill="x", pady=10)

        label = tk.Label(self, text="Blockchain name", font=controller.body_font)
        label.pack(side="top", fill="x", pady=10)
        e3 = tk.Entry(self, width=30)
        e3.pack(side="top")
        
        label = tk.Label(self, text="Transaction name", font=controller.body_font)
        label.pack(side="top", fill="x", pady=10)
        e4 = tk.Entry(self, width=30)
        e4.pack(side="top")
        
        button3 = tk.Button(self, text="Search",
                            command=lambda: self.Search(e3.get(), e4.get()),
                            height=5, width=30, bg='#6666FF')
        button3.pack(pady=5)

        button4 = tk.Button(self, text="Back",
                   command=lambda: controller.show_frame("HomePage"),
                   height=5, width=30, bg='#6666FF')
        button4.pack(pady=5)
        
    def Search(self, Blockchain_name, Transaction_name):
        
        # 1. load blockchain
        file = os.path.dirname(sys.argv[0]) + "/Blockchain/" + Blockchain_name + r'.json'
        
        with open(file) as input:
            input = json.load(input)
            df = pd.DataFrame.from_dict(input, orient='columns')
            
        columns = ['hash','user','date','Transaction_name', 'Transaction_type', 'Password', 'filepath','Blockchain_name']
    
        # 2. Check if user is on the blockchain:
        users = df.loc[df['Transaction_name'] == username]['Transaction_name'].values
        correct_passwords = df.loc[df['Transaction_name'] == username]['Password'].values
        
        if username in users:
            if user_password in correct_passwords:
                # 3. print results
                results = df.loc[df['Transaction_name'] == Transaction_name].values.tolist()
                
                if results:
                    results = [r for r in results]
                    results = [item for sublist in results for item in sublist]
                    results = [columns[i%len(columns)] + ':  ' + str(results[i]) for i in range(len(results))]
                    label = [tk.Label(self, text=t) for t in results]
                
                if not results:
                    results = ("No such entry in this blockchain.")
                    label = [tk.Label(self, text=results)]
                
            else:
                results = 'password incorrect'
                label = [tk.Label(self, text=results)]
        else:
            results = 'user not found: '+ username
            label = [tk.Label(self, text=results)]
        
        y = 450
        for i in label:
            i.pack(side="top", fill="x", pady=0)
            i.place(x=10, y=y)
            y += 25


################
### Back End ###
################

class BackEnd():

    # Functions triggered by buttons
    def Save_ledger():
        
        with open('ledger.json', 'w') as output:
                json.dump(ledger, output)
                output.write(str(ledger))
        
        df = pd.DataFrame(ledger)
        df.to_csv(r'Blockchain\ledger.csv', header=False, index=False)
        df.to_json('Blockchain\ledger.json')

        
        print("saved!")
        
    def whitespace(height):
        whitespace = tk.Frame(width=600, height=height, bg="white")
        whitespace.pack()

    def make_button(text, command):
        b = Button(text=text, command=command, height=5, width=30, bg='#ABB02A')
        b.pack()
            
    def Close():
        window.quit()

if __name__ == "__main__":
    app = App()
    app.mainloop()

## To Do ##

# 1. fix prompts
# 2. video opnemen

#
#        whitespace = tk.Frame(width=600, height=200, bg="white")
#        whitespace.pack()
#        whitespace.place(y=450)
