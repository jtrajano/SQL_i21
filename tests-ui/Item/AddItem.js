/**
 * Created by CCallado
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)
        .login('AGADMIN', 'AGADMIN', 'AG')


        .done()
});

