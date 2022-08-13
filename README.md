This repo contains the resources needed to create an [AresMUSH](https://aresmush.com) server image on DigitalOcean using [Packer](https://www.packer.io/intro/getting-started/install.html).

## AresMUSH 1-Click Image

You can create an AresMUSH server using the 1-click droplet image on the [DigitalOcean Marketplace](https://marketplace.digitalocean.com/apps/aresmush).

The AresMUSH 1-click image comes with all the software you need to run your own [AresMUSH](https://aresmush.com) server. There are just a few steps you must do to finalize the installation and configure your game.

**For a detailed walk-through of how to use this image, see the [AresMUSH OneClick Installation Instructions](https://aresmush.com/tutorials/install/oneclick.html).**

> Note: If using a custom domain for your game, make sure the DNS is set up **before** attempting to finalize the installation.

After creating your own droplet using the 1-click image:

1. Connect to your new droplet [using SSH](https://www.digitalocean.com/docs/droplets/how-to/connect-with-ssh/) as **root**: `ssh root@your_droplet_public_ipv4`.
2. Run the following commands, and follow the prompts to enter your game information:

```
cd /etc/aresmush
./complete_setup
```

> The setup script will create an **ares** user. Save this password in a safe place. You must use the ares user for all of your game administration tasks.

3. Once the installation has finished, it is strongly recommended that you secure your web portal by installing a security certificate. Log in to your droplet as the **ares** user and run the following commands to set up [Certbot](https://certbot.eff.org/):

```
cd aresmush
bin/certs
```

4. Reboot the server.

Your game will now be running at `https://yourcustomdomain.com` or `http://your_droplet_public_ipv4`. You can also connect through a MUSH client using the port you configured during setup. See [Next Steps](https://aresmush.com/tutorials/install/next-steps.html) for getting started with your game.

If you run into any trouble during the installation process, ask for help on the [AresMUSH Forum](https://forum.aresmush.com).

## License

See [License](https://aresmush.com/license.html)