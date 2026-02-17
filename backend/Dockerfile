# Use lightweight Node image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .    

# Expose backend port
EXPOSE 7000

# Start app
CMD ["node", "server.js"]
