# Creates Docker Container
# docker run -it -p 1881:1881 -e URL_prefix="/test" --name test versadesk/fuxa:1.2.2
# docker build -t versadesk/fuxa:1.2.2 .

FROM node:18-bookworm

ARG NODE_SNAP=false

RUN apt-get update && apt-get install -y dos2unix nginx gettext && \
    mkdir -p /usr/src/app/FUXA

# Change working directory
WORKDIR /usr/src/app/FUXA

# ADD FUXA File
COPY . .

# Change working directory
WORKDIR /usr/src/app

# Install build dependencies for node-odbc
RUN apt-get update && apt-get install -y build-essential unixodbc unixodbc-dev

# Convert the script to Unix format and make it executable
RUN dos2unix FUXA/odbc/install_odbc_drivers.sh && chmod +x FUXA/odbc/install_odbc_drivers.sh

WORKDIR /usr/src/app/FUXA/odbc
RUN ./install_odbc_drivers.sh

# Change working directory
WORKDIR /usr/src/app

# Copy odbcinst.ini to /etc
RUN cp FUXA/odbc/odbcinst.ini /etc/odbcinst.ini

# Install Fuxa server
WORKDIR /usr/src/app/FUXA/server
RUN npm install

# Install options snap7
RUN if [ "$NODE_SNAP" = "true" ]; then \
    npm install node-snap7; \
    fi

# Workaround for sqlite3 https://stackoverflow.com/questions/71894884/sqlite3-err-dlopen-failed-version-glibc-2-29-not-found
RUN apt-get update && apt-get install -y sqlite3 libsqlite3-dev && \
    apt-get autoremove -yqq --purge && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*  && \
    npm install --build-from-source --sqlite=/usr/bin sqlite3

# Add project files
ADD . /usr/src/app/FUXA

# Set working directory
WORKDIR /usr/src/app/FUXA/server

# Expose port
EXPOSE 1881

# Start the server
CMD [ "npm", "start" ]
