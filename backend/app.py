from flask import Flask, render_template, request, redirect, url_for, session
from google.oauth2 import service_account
import googleapiclient.discovery
import os
import qrcode
import random
import schedule
import time
import threading
import shutil
from keys.keys import verifySid 

app = Flask(__name__)
app.secret_key = 'that_is_top_sceret' 

# Load the credentials from the service account key JSON file
credentials = service_account.Credentials.from_service_account_file(
    os.path.join(os.path.dirname(os.path.abspath(__file__)),'/keys/credentials.json'),
    scopes=['https://www.googleapis.com/auth/spreadsheets'],
)

# Create a Google Sheets API service
sheets_service = googleapiclient.discovery.build('sheets', 'v4', credentials=credentials)

@app.route('/')
def index():
    error = session.pop('error', None)
    return render_template('index.html', error=error)

@app.route('/process_login', methods=['POST'])
def process_login():
    # Get the data from the login form
    user_id = request.form['id']
    password = request.form['password']

    # Verify the ID and password against the Google Sheet
    sid = verify_login(user_id, password)

    if sid:
        # Store sid in the session
        session['sid'] = sid
        return redirect(url_for('date_input'))
    else:
        # Store an error message in the session
        session['error'] = "Invalid Course Id or Password"
        return redirect(url_for('index'))

def verify_login(user_id, password):

    sid = verifySid
    range_ = 'Sheet1!A:C' 

    result = sheets_service.spreadsheets().values().get(
        spreadsheetId=sid,
        range=range_
    ).execute()

    values = result.get('values', [])

    for row in values:
        if len(row) >= 3 and row[0].lower() == user_id.lower() and row[1] == password:
            return row[2]  # Return the value from the third column (C)

    return None  # No match found


@app.route('/date_input')
def date_input():
    # Retrieve sid from the session
    sid = session.get('sid', None)
    if sid is None:
        # Handle the case where sid is not in the session
        return redirect(url_for('index'))

    return render_template('date.html')

@app.route('/process_date_shift', methods=['POST'])
def process_date_shift():
    sid = session.get('sid', None)
    if sid is None:
        # Handle the case where sid is not in the session 
        return redirect(url_for('index'))

    date_value = request.form['date']

    shift_value = request.form.get('shift', '')

    if shift_value != "":
        date_value = date_value + "_" + shift_value 
    session['date']=date_value
    # Update Google Sheet with the date_value and generate a random 8-digit pin
    update_sheet(sid, date_value)

    # Redirect to success page
    return redirect(url_for('qr'))

@app.route('/qr')

def qr():
    # Retrieve sid from the session
    sid = str(session.get('sid', None))
    date = str(session.get('date', None))
    pin = str(session.get('pin', None))

    sid = "ca" + sid
    date = "cb" + date
    pin = "cb" + pin

    # Generate QR codes
    generate_and_save_qr_code(sid, f"qrcodes/{sid}.png")
    generate_and_save_qr_code(date, f"qrcodes/{date+pin}.png")
    generate_and_save_qr_code(pin, f"qrcodes/{pin}.png")

    if sid is None or date is None or pin is None:
        # Handle the case where sid is not in the session 
        return redirect(url_for('index'))

    return render_template('qr.html', sid=sid, date=date, pin=pin)

def generate_and_save_qr_code(data, file_path):
    try:
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(data)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")
        img.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', file_path))
    except Exception as e:
        print(f"Error generating and saving QR code: {e}")
def get_column_letter(column_index):
    """
    Convert a 0-based column index to the corresponding column letter.
    """
    column_letter = ""
    while column_index >= 0:
        column_letter = chr((column_index % 26) + 65) + column_letter
        column_index = (column_index // 26) - 1
    return column_letter


def update_sheet(sid, date_value):
    # Get the current values from the sheet
    range_ = 'Sheet1!1:2'  # Assuming the data is in the first two rows
    result = sheets_service.spreadsheets().values().get(
        spreadsheetId=sid,
        range=range_
    ).execute()

    values = result.get('values', [])

    # Find the first empty cell in the first row
    new_column_index = len(values[0]) if values else 1
    session['col']=new_column_index

    # Update the sheet with the new date_value in the first empty cell
    new_range_date = f'Sheet1!{get_column_letter(new_column_index)}1'
    new_values_date = [[date_value]]
    sheets_service.spreadsheets().values().update(
        spreadsheetId=sid,
        range=new_range_date,
        valueInputOption='RAW',
        body={'values': new_values_date}
    ).execute()


    pin_value = random.randint(10000000, 99999999)
    session['pin']=pin_value
    new_range_pin = f'Sheet1!{get_column_letter(new_column_index)}2'  
    new_values_pin = [str(pin_value)]  
    sheets_service.spreadsheets().values().update(
        spreadsheetId=sid,
        range=new_range_pin,
        valueInputOption='RAW',
        body={'values': [new_values_pin]}  
    ).execute()

    new_column_range = f'Sheet1!{get_column_letter(new_column_index + 1)}:{get_column_letter(new_column_index + 1)}'
    sheets_service.spreadsheets().batchUpdate(
        spreadsheetId=sid,
        body={
            'requests': [
                {
                    'insertDimension': {
                        'range': {
                            'sheetId': 0, 
                            'dimension': 'COLUMNS',
                            'startIndex': new_column_index+1,
                            'endIndex': new_column_index + 2
                        },
                        'inheritFromBefore': False
                    }
                }
            ]
        }
    ).execute()







@app.route('/delete_qr_codes', methods=['POST'])
def delete_qr_codes():

   
    try:
        pin_column_index=session.get('col',None)
        sid=session.get('sid',None)
        if pin_column_index:
            new_range_pin = f'Sheet1!{get_column_letter(pin_column_index)}2'
            new_pin_value=random.randint(10000, 99999)
            new_values_pin = [str(new_pin_value)]
            sheets_service.spreadsheets().values().update(
            spreadsheetId=sid,
            range=new_range_pin,
            valueInputOption='RAW',
            body={'values': [new_values_pin]}
            ).execute()
        else:
            print(f"Couldn't change pin: {session.get('sid', None)} {session.get('date', None)}")
    except Exception as e:
        print(f"Error updating pin: {e}")




    try:

        sid = str(session.get('sid', None))
        date = str(session.get('date', None))
        pin = str(session.get('pin', None))




        if sid:
            sid="ca"+sid
            date="cb"+date
            pin="cb"+pin
            # Delete QR code files
            for code_type in [sid, date+pin, pin]:
                try:
                    file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),"/static/qrcodes/{code_type}.png")
                    print(file_path)
                    if os.path.exists(file_path):
                        os.remove(file_path)
                except Exception as e:
                    print(f"Error deleting QR codes (directory): {e}")

        # Clear session variables
        session.pop('sid', None)
        session.pop('date', None)
        session.pop('pin', None)

        return redirect(url_for('index'))

    except Exception as e:
        # Handle errors (log or redirect to an error page)
        print(f"Error deleting QR codes: {e}")
        return redirect(url_for('index'))
    

def clear_and_recreate_qrcodes_folder():

    try:
        # Delete the existing qrcodes folder
        shutil.rmtree(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'qrcodes'))

        # Recreate the qrcodes folder
        os.makedirs(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'qrcodes'))
    except Exception as e:
        print(f"Error clearing and recreating qrcodes folder: {e}")






# Schedule the job to run daily at 11:59 pm
schedule.every().day.at("23:59").do(clear_and_recreate_qrcodes_folder)

# Function to run the scheduled jobs in a separate thread
def run_scheduled_jobs():
    while True:
        schedule.run_pending()
        time.sleep(20)

# Start the thread for running scheduled jobs
scheduler_thread = threading.Thread(target=run_scheduled_jobs)
scheduler_thread.start()



if __name__ == '__main__':

    app.run(debug=True)