from cryptography.fernet import Fernet

# Generate a key
key = Fernet.generate_key()

# Print the key (keep it secret!)
print(key.decode())  # Convert to string for storage if needed