# Authorization

Welcome! An introductory user authorization project is presented to your attention.

#### Initial defaults

To initialize a project with basic configurations, run the command:

```bash
make init
```

after initialization, edit the `.env` and `docker-compose.yml` files as you like.

### Hosts

To access the authorization application through a web browser, add the following line to the hosts configuration file `/etc/hosts`:

```txt
127.0.0.1 auth.local
```