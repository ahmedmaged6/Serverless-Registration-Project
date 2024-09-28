document.getElementById('signup-form').addEventListener('submit', async function (event) {
    event.preventDefault(); // Prevent the form from submitting
    const firstName = document.getElementById('first-name').value; 
    const secondName = document.getElementById('second-name').value; 
    const email = document.getElementById('email').value;

    try {
        // Call Lambda to save user info to DynamoDB
        const response = await fetch('https://qbuntqmic6.execute-api.us-east-2.amazonaws.com/SecondStage/signup/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, firstName, secondName })
        });

        const result = await response.json();

        if (response.ok) {
            sessionStorage.setItem('userEmail', email);
            alert('Signup successful!');
            window.location.href = 'profile.html';
        }
        else if(response.status === 400 && result.error === 'Email already exists'){
            alert('This email is already registered.');
        }
        else {
            alert(`Error: ${result.error}`);
        }
    } catch (error) {
        console.log(error);
        alert('Error during signup');
    }
});


async function getUserProfile() {
    const email = sessionStorage.getItem('userEmail'); // Assuming you saved the email in session storage after login

    try {
        const response = await fetch(`https://qbuntqmic6.execute-api.us-east-2.amazonaws.com/SecondStage/profile?email=${email}`, { // Update with your API Gateway URL
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        const result = await response.json();
        if (response.ok) {
            document.getElementById('firstName').value = result[0].firstName;
            document.getElementById('secondName').value = result[0].secondName;
            document.getElementById('email').value = result[0].email;

        } else {
            alert(`Failed to fetch profile: ${result.error}`);
        }
    } catch (error) {
        console.error('Error fetching profile:', error);
        alert('An error occurred while fetching the profile.');
    }
}
