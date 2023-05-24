from typing import NoReturn
from io import TextIOWrapper
from sys import exit as sysExit, argv

EXIT_SUCCESS: bool = False
EXIT_FAILURE: bool = True

NGROK_LOG_PATH: str = "/var/log/ngrok/" + argv[1]
CLIENT_ENV_PATH: str = ""
SERVICES_URL_BASE: list = [
    'REACT_APP_URL_REST_API=',
    'REACT_APP_URL_STORAGE=',
    'REACT_APP_MY_SECRET='
]


def getPublicURL() -> str:
    with open(NGROK_LOG_PATH, 'r') as log:
        url: str = None
        targetLine: list = None
        for line in log:
            if line.find("url=http://", 0, len(line)) > 0:
                targetLine = line.split(' ')
                url = targetLine[len(targetLine) - 1][4:]
                print(" URL= " + url[:-1])
        log.close()
        return url


def writeToFile(url: str) -> None:
    fp: TextIOWrapper = open(CLIENT_ENV_PATH, 'w')
    for i, service in enumerate(SERVICES_URL_BASE):
        if i == 0:
            fp.write(service + url)
        else:
            if i == len(SERVICES_URL_BASE) - 1:
                fp.write(service)
            else:
                fp.write(service + '\n')
    fp.close()


def main() -> NoReturn:
    print(" Getting ngrok public URL . . .")
    url: str = getPublicURL()
    print(" Writing URL to client environment file . . .")
    writeToFile(url)
    print(" Done!")
    sysExit(EXIT_SUCCESS)


if __name__ == '__main__':
    main()