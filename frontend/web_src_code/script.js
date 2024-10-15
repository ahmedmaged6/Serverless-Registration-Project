// Define the base API URL
const API_URL = 'https://33435q44ue.execute-api.us-east-2.amazonaws.com/Production';

                                       //signup & confirm_code Script
// Signup Form Submit Handler
document.getElementById('signup-form')?.addEventListener('submit', async function (event) {
    event.preventDefault();

    const userData = {
        firstName: document.getElementById('first-name').value,
        secondName: document.getElementById('second-name').value,
        email: document.getElementById('email').value,
        password: document.getElementById('password').value,
    };
    console.log("userData", JSON.stringify(userData));

    try {
        const response = await fetch(`${API_URL}/signup`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userData)
        });

        const result = await response.json();
        console.log(response);
        console.log(result);

        if (response.ok) {
            console.log(result.message);
            document.getElementById("confirmation-modal").style.display = "block";
        } else {
            console.log(result.message);
            alert("Sign Up Failed: " + result.error);
        }
    } catch (error) {
        alert("Error During Sign Up", error);
    }
});

// Function to confirm signup
async function confirmSignup() {
    const email = document.getElementById("email").value;
    const confirmationCode = document.getElementById("confirmation-code").value;

    try {
        const response = await fetch(`${API_URL}/confirm_code`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, confirmationCode })
        });

        const result = await response.json();
        console.log(response);
        console.log(result);

        if (response.ok) {
            alert(result.message);
            closeModal();
            window.location.href = "login.html";
        } else {
            alert(result.message + ", " + result.error);
        }
    } catch (error) {
        alert("Error During Confirm Code: " + error);
    }
}

function closeModal() {
    document.getElementById("confirmation-modal").style.display = "none";
}

                                        //login Script
// Login Form Submit Handler
document.getElementById("login-form")?.addEventListener("submit", async function (event) {
    event.preventDefault();
    const email = document.getElementById("username").value;
    const password = document.getElementById("password").value;
    console.log("Email:", email);
    console.log("Password:", password);

    try {
        const response = await fetch(`${API_URL}/login`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ email, password })
        });

        const result = await response.json();
        console.log("Token:" + result.data.AccessToken);

        if (response.ok) {
            console.log(result.message);
            localStorage.setItem("access_token", result.data.AccessToken);
            window.location.href = "profile.html";
        } else {
            alert("Login failed:" + result.error);
        }
    } catch (error) {
        alert("Error During Login " + error);
    }
});

                                        //profile page Script

// Fetch user details using token
async function fetchUserProfile() {
    const token = localStorage.getItem('access_token');
    console.log(token);

    const loadingElement = document.getElementById('loading');
    const profileForm = document.getElementById('profile-form');

    // Show the loading indicator
    loadingElement.style.display = 'block';

        try {
            const response = await fetch(`${API_URL}/profile`, {
                method: 'GET',
                headers: {
                    'Authorization':`Bearer ${token}`,
                    'Content-Type':'application/json'
                }
            });

            if (response.ok) {
                const data = await response.json();
                const firstName = data.firstName;
                const secondName = data.secondName;
                const email = data.email;

                // Set the greeting text with first ,second name and email
                document.getElementById('firstName').value = firstName;
                document.getElementById('secondName').value = secondName;
                document.getElementById('email').value = email;

                // Hide the loading indicator and show the form
                loadingElement.style.display = 'none';
                profileForm.style.display = 'block';
            } else {
                console.error('Failed to fetch user details.');
            }
        } catch (error) {
            console.error('Error while trying to view profile', error);
        }
    }


// Logout function
function logout() {
    // Clear the access token from localStorage
    localStorage.removeItem('access_token');
    
    // Clear the forward history
    history.pushState(null, null, location.href);
    window.onpopstate = function () {
    history.go(1);  // Prevent forward navigation after logout
    };
    
    window.location.href = 'login.html'; // Change this to your actual login page URL
}


